source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'sentry-raven'
gem 'aws-sdk-s3', '~> 1', require: false
gem 'aws-sdk-sqs'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'decent_exposure'
gem 'expa', '0.1.2.10', git: 'http://github.com/AIESEC-no-Brasil/expa-rb'
gem 'faker'
# gem 'graphql-client'
gem 'httparty'
gem 'mechanize'
gem 'pg', '>= 0.18', '< 2.0'
gem 'podio'
gem 'puma', '~> 3.11'
gem 'rack-cors'
gem 'rails', '5.2.1'
gem 'shoryuken'
gem 'slack-notifier'
gem 'swagger_ui_engine'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'whenever', require: false

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'guard-rspec', require: false
  gem 'guard-rubocop'
  gem 'rspec-rails', '~> 3.7'
  gem 'rubocop', require: false
  gem 'rubocop-rspec'
  gem 'shoulda-matchers'
end

group :development do
  gem 'capistrano',         require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano3-puma',   require: false
  gem 'libnotify'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'simplecov', require: false
end
