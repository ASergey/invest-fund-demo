FactoryGirl.define do
  factory :currency do
    sequence(:name) { |n| "currency_name-#{n}" }
    sequence(:symbol) { |n| "cur-#{n}" }
  end

  factory :currency_usd, parent: :currency do
    name    'United States dollar'
    symbol  'USD'
    default true
  end

  factory :currency_btc, parent: :currency do
    name    'Bitcoin'
    symbol  'BTC'
  end

  factory :currency_ltc, parent: :currency do
    name    'Litecoin'
    symbol  'LTC'
  end
end
