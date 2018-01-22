FactoryGirl.define do
  factory :instrument_group do
    sequence(:name)  { |n| "Group#{n}" }
    sequence(:description) { 'Some instrument group#{n}' }
  end
end
