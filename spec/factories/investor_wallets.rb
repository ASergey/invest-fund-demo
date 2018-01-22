FactoryGirl.define do
  factory :investor_wallet do
    user
    currency
    sequence(:name)     { |n| "Wallet-#{n}" }
    sequence(:address)  { |n| "WalletHashAddress#{n}" }
  end
end
