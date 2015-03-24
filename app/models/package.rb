# This model represent an Emacs elpa compatible package
class Package

  include Mongoid::Document
  include Mongoid::Timestamps
  include Concerns::Package::Fields
  include Concerns::Package::Callbacks
  include Concerns::Package::Validations
  # This accessor will contains data of the file to upload like
  # content type, base64 encoded data and file name
  attr_accessor :package_data, :dependencies_data, :version_data

  validates :name, presence: true

  index({ name: 1 }, { unique: true, background: true })
  index({ 'versions.version' => 1 }, { background: true })
end
