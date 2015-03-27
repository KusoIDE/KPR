require 'faker'
require 'base64'

pkg_file = "#{Rails.root}/spec/fixtures/sample_pkg.tar"
package_data = { filename: 'sample_pkg.tar',
                 content_type: 'application/x-tar',
                 data: Base64.strict_encode64(File.read(pkg_file))
               }


Fabricator :package do
  name { Faker::App.name }
  versions { [ Fabricate(:package_version, version: '0.9.0'),
               Fabricate(:package_version, version: '1.0.0')] }
  description { Faker::Lorem.paragraph }
end


Fabricator :package_params, from: :package do
  name { Faker::App.name }
  versions { [ Fabricate.build(:package_version, version: Faker::App.version),
               Fabricate.build(:package_version, version: Faker::App.version)] }

  description { Faker::Lorem.paragraph }
  package { package_data }
  dependencies []
  dev_dependencies []

  home_page         { Faker::Internet.url }
  documentation_url { Faker::Internet.url }
  download_url      { Faker::Internet.url }
  bug_tracker_url   { Faker::Internet.url }
  wiki_url          { Faker::Internet.url }
  source_code_url   { Faker::Internet.url }

  authors [{ first_name: Faker::Name.name, last_name: Faker::Name.name,
             email: Faker::Internet.email }]
  owners { [Fabricate(:user)] }
end

Fabricator :package_without_name, from: :package_params do
  name nil
end

Fabricator :package_without_version, from: :package_params do
  version nil
end

Fabricator :package_without_description, from: :package_params do
  description nil
end

Fabricator :package_without_package, from: :package_params do
  package nil
end
