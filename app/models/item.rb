class Item < ActiveRecord::Base
  attr_accessible :name

  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings

  def tag_list
    tags.to_tag_list
  end

  def tag_list=(tag_list_str)
    self.tags = Tag.from_tag_list(tag_list_str)
  end
end
