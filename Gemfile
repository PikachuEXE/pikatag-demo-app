source 'https://rubygems.org'

ruby '2.0.0'

gem 'rails', '3.2.12'

# Use unicorn as the app server
gem 'unicorn'
gem 'foreman'

# Database
gem 'mongoid', '~> 3.0.0'
gem 'mongoid_rails_migrations'

# Strong Parameters
gem 'strong_parameters'

gem 'haml-rails'
gem 'jquery-rails'

gem 'simple_form'

gem 'quiet_assets'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'fuubar', group: :test
  gem 'shoulda-matchers', group: :test # More Rails matchers
  gem 'rspec-given', group: :test # Given/When/Then

  gem 'database_cleaner', group: :test
  gem 'mongoid-rspec', group: :test

  # Generate fake data
  gem 'ffaker'
  gem 'factory_girl_rails'

  gem 'spork'

  ## Debugging
  # lets pry
  gem 'pry-rails'

  # Load .env into ENV
  gem 'dotenv-rails'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
