class Tag
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  validates_presence_of :name
  validates_uniqueness_of :name

  index({name: 1})

  has_and_belongs_to_many :items

  SEPERATOR = ','

  def self.to_tag_list(tags)
    tags.collect(&:name).join(SEPERATOR)
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
