FactoryGirl.define do
  factory :item do
    sequence(:name){ |n| "Item Name #{n}" }
  end
end
