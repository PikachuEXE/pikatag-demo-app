class Tag < ActiveRecord::Base
  attr_accessible :name

  validates_presence_of :name
  validates_uniqueness_of :name

  SEPERATOR = ','

  def self.tag_list
    pluck(:name).join(SEPERATOR)
  end

  def self.tag_list=(tag_list_str)
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
