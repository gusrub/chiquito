source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'

# Queues
gem 'sidekiq'

# Allows us to use per-environment configurations and have it ready as soon as
# the app is loaded (e.g. before we initialize database etc.)
gem 'dotenv-rails', groups: [:development, :test], require: 'dotenv/rails-now'

# This is a temporary hack to be able to run the sidekiq web interface locally
# see https://github.com/rack/rack/pull/1428
gem 'rack', git: 'https://github.com/rack/rack', branch: 'master'

# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 3.11'

# Frontend stuff
gem 'uglifier', '>= 1.3.0'
gem 'bootstrap', '~> 4.x'
gem 'jquery-rails'
gem 'font-awesome-rails', '~>4.x'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'awesome_print'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem 'factory_bot_rails'
  gem 'faker'  
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
