module Concerns::Package::Validations
  extend ActiveSupport::Concern

  included do
    validate :unique_version
    validate :valid_package_data, on: :create
    validate :base64_format, on: :create
    #validate :valid_dependencies
    #validate :content_type
  end

  def unique_version
    if versions.where(version: version).exists?
      errors.add :versions, 'Version already exists'
    end
  end

  def valid_package_data
    if package_data.nil? || package_data.empty?
      errors.add :package, 'Can not be nil or empty.'
      return false
    end

    fn   = package_data['filename'].present?
    ct   = package_data['content_type'].present?
    data = package_data['data'].present?

    if !(fn && ct && data)
      errors.add :package, "Should contains 'filename', 'data', 'content_type'"
      return false
    end
  end

  def base64_format
    base64_part = package_data['data'].split(',')[-1]

    begin
      @cached_content = Base64.strict_decode64(base64_part)
    rescue ArgumentError
      errors.add :package, 'Invalid base64'
    end
  end
end
