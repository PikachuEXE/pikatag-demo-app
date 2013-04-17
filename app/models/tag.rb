class Tag
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false

  index({name: 1})

  has_and_belongs_to_many :items

  SEPARATOR = ','

  def self.search_by_name_alike(name)
    where(name: /^#{name}/i)
  end

  def self.to_tag_list(tags)
    tags.collect(&:name).join(SEPARATOR)
  end

  def self.from_tag_list(tag_list_str)
    tag_names = tag_list_str.split(SEPARATOR).reject(&:blank?)
    tag_names.collect do |tag_name|
      find_or_create_by_name(tag_name)
    end
  end

  private

  def self.find_or_create_by_name(name)
    where(name: name).first || create!(name: name)
  end
end
