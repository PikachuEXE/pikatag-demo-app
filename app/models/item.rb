class Item
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  validates_presence_of :name
  validates_uniqueness_of :name

  index({name: 1})

  has_and_belongs_to_many :tags

  def tag_list
    Tag.to_tag_list(tags)
  end

  def tag_list=(tag_list_str)
    self.tags = Tag.from_tag_list(tag_list_str)
  end
end
