FactoryGirl.define do
  factory :wallet do
    currency
    sequence(:name)     { |n| "Wallet-#{n}" }
    sequence(:address)  { |n| "WalletHashAddress#{n}" }
  end
end
