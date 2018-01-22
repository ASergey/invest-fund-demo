FactoryGirl.define do
  factory :instrument do
    sequence(:name)  { |n| "Instrument#{n}" }
    notes   'Some ICO investment instrument'
  end
end
