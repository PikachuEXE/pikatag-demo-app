class Item < ActiveRecord::Base
  attr_accessible :name, :tag_list

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :taggings, as: :taggable,
           inverse_of: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  def tag_list
    tags.to_tag_list
  end

  def tag_list=(tag_list_str)
    self.tags = Tag.from_tag_list(tag_list_str)
  end
end
