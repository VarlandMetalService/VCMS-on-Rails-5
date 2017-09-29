source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

#  Rails default gems
gem 'coffee-rails',                 '~> 4.2'
gem 'rails',                        '~> 5.1.3'
gem 'puma',                         '~> 3.7'
gem 'sass-rails',                   '~> 5.0'
gem 'turbolinks',                   '~> 5'
gem 'uglifier',                     '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Project specific gems
gem 'american_date'
gem 'awesome_nested_set'
gem 'bootstrap',                    '~> 4.0.0.beta'
gem 'bootstrap-datepicker-rails'
gem 'carrierwave',                  '~> 1.0'
gem 'cocoon',                       '1.2.6'
gem 'font-awesome-rails'
gem 'google_drive'
gem 'has_scope'
gem 'holder_rails'
gem 'jquery-rails'
gem 'mini_magick',                   '~> 4.3'
gem 'mysql2',                       '~> 0.3.18'
gem 'omniauth-google-oauth2',       '~> 0.2.1'
gem 'rest-client',                  '~> 2.1.0.rc1'
gem 'sidekiq'
gem 'will_paginate',                '~> 3.0.6'
gem 'will_paginate-bootstrap',      '1.0.1'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
