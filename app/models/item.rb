class Item < ActiveRecord::Base
  attr_accessible :name

  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings
end
