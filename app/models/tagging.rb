class Tagging < ActiveRecord::Base
  attr_accessible :created_at, :tag, :taggable

  belongs_to :tag
  belongs_to :taggable, polymorphic: true
end
