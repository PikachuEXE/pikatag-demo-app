# Mongoid

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner[:mongoid].start
  end

  config.after(:each) do
    DatabaseCleaner[:mongoid].clean
  end


  config.before(:each) do
    Mongoid::IdentityMap.clear
  end


  config.include Mongoid::Matchers
end
