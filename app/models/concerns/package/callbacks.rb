require 'tempfile'

module Concerns::Package::Callbacks

  extend ActiveSupport::Concern

  included do

    after_initialize :init
      # Upload and validate the package
    before_save :upload_file
    before_save :urlify_name

    before_save :reorder_versions
  end

  def init
    self.dependencies             ||= []
    self.development_dependencies ||= []
    self.sorted_versions          ||= []
  end

  # Upload and validate the package
  def upload_file

    return true if !package_data.present? && version.nil?

    file_data = extract_data(package_data)
    filename, ext = process_name(package_data[:filename])

    write_file_data(filename, ext, file_data) do |file|

      # TODO: Validate the size
      file_size = File.size(file)

      # TODO: Validate the content type

      fs = Mongoid::GridFS.put(file)
      # Save the package and nested objects
      save_version(fs)

      Rails.logger.info "PATH: #{filename} - #{package_data[:content_type]} - #{file_size}"
      Rails.logger.info "Buffer size: #{file_data.size}"
    end
    true
  end

  # Save the package and nested objects
  def save_version(fs)
    new_version = PackageVersion.new(version: version,
                                     grid_fs_id: fs.id,
                                     checksum: checksum,
                                     content_type: package_data[:content_type],
                                     created_at: Time.now)

    self.dependencies.each do |dep, ver|
      new_version.dependencies << create_dependency(dep, ver)
    end

    self.development_dependencies.each do |dep, ver|
      new_version.development_dependencies << create_dependency(dep, ver)
    end

    self.versions << new_version
  end

  private

  # Create a dependency object
  def create_dependency(dep, ver)
    version = ver
    version = '0' if ['', '*', 'latest'].include? ver

    PackageDependency.new(name: dep,
                          version: version)
  end

  def process_name(name)
    random_name = SecureRandom.hex(32)

    original_filename = File.basename(name, '.*')
    ext = File.extname(name)
    filename = "#{original_filename}_#{random_name}#{ext}"

    [filename, ext]
  end

  def write_file_data(file_name, extname, file_data)
    file = Tempfile.new([file_name, extname])
    file.binmode
    file.write(file_data)
    yield file

  # TODO: Fix this stupid rescue
  rescue Exception => e
    Rails.logger.error "ERROR Uploading file: #{e.to_s}"
    raise

  ensure
    file.close
    file.unlink
  end

  def extract_data(package)
    require 'digest/sha1'

    if package[:data].present?
      base64_part = package[:data].split(',')[-1]
      decoded_data = @cached_content || Base64.strict_decode64(base64_part)

      self.checksum = Digest::SHA1.hexdigest decoded_data
      #data = StringIO.new(decoded_data)
      return decoded_data
    end
    nil
  end

  def urlify_name
    self.urlified_name = name.parameterize
  end

  def reorder_versions
    self.sorted_versions << version
    self.sorted_versions = sorted_versions.sort do |a, b|
      Gem::Version.new(a) <=> Gem::Version.new(b)
    end
  end

  private

  def valid_package_combination
    return true if !package_data.present? && verions.nil?

    if package_data.present?
      fn   = package_data['filename'].present?
      ct   = package_data['content_type'].present?
      data = package_data['data'].present?

      return true if (fn && ct && data) && !version.nil?
    end
    false
  end
end
