module Lets
  extend ActiveSupport::Concern

  module ClassMethods
    def lets(*names, &block)
      names.each do |name|
        let(name, &block)
      end
    end

    def lets!(*names, &block)
      names.each do |name|
        let!(name, &block)
      end
    end
  end

end

RSpec.configure do |config|
  config.include Lets
end
