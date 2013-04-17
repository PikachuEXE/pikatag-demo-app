require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do

  ENV["RAILS_ENV"] ||= 'test'
  require 'rake/dsl_definition' # Make sure RubyMine can also run tests
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'

  # Cucumber like syntax in RSpec
  require 'rspec/given'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # we want to render views
    config.render_views

    # No FactoryGirl prefix
    config.include FactoryGirl::Syntax::Methods
  end
end

Spork.each_run do
  # Reload FactoryGirl
  FactoryGirl.reload

  # Reload shared examples
  Dir[Rails.root.join("spec/shared_examples/**/*.rb")].each {|f| require f}
end
