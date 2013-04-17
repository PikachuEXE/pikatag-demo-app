class Tag < ActiveRecord::Base
  attr_accessible :name

  has_many :taggings,
           inverse_of: :tag, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name

  SEPERATOR = ','

  def self.to_tag_list
    pluck(:name).join(SEPERATOR)
  end

  def self.from_tag_list(tag_list_str)
    tag_names = tag_list_str.split(SEPERATOR).reject(&:blank?)
    tag_names.collect do |tag_name|
      find_or_create_by_name(tag_name)
    end
  end

  private

  def self.find_or_create_by_name(name)
    where(name: name).first || create!(name: name)
  end
end
