require 'faker'

pkg_file = File.new("#{Rails.root}/spec/fixtures/sample_pkg.tar")
PKG = ActionDispatch::Http::UploadedFile.new(tempfile: pkg_file,
                                             filename: 'sample_pkg.tar')
FactoryGirl.define do
  factory :package do
    name Faker::App.name
    version Faker::App.version
    description Faker::Lorem.paragraph
    package PKG

    factory :package_without_name do
      name nil
    end

    factory :package_without_version do
      version nil
    end

    factory :package_without_description do
      description nil
    end

    factory :package_without_package do
      package nil
    end

  end
end
