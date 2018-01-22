FactoryGirl.define do
  factory :kyc_document do
    user
    sequence(:first_name) { |n| "First name #{n}" }
    sequence(:last_name)  { |n| "Last name #{n}" }
    sequence(:address)    { |n| "Adress #{n}" }
  end
end
