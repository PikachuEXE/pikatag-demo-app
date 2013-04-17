require 'spec_helper'

describe Item do
  describe 'validations' do
    it {should validate_presence_of :name}
    it {should validate_uniqueness_of :name}
  end

  describe 'associations' do
    it {should have_and_belong_to_many :tags}
  end
end
