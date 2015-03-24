# This document embeds on Package
class PackageVersion

  include Mongoid::Document
  include Mongoid::Timestamps

  field :version
  field :grid_fa_id
  field :content_type
  field :checksum

  field :downloads, type: Integer, default: 0

  embeds_many :dependencies, class_name: 'PackageDependency'
  embeds_many :development_dependencies, class_name: 'PackageDependency'

  embedded_in :package
end
