FactoryGirl.define do
  factory :fund_balance do
    currency
    amount 100.0

    trait :usd do
      currency { create(:currency_usd) }
      amount 100_000.0
    end

    trait :btc do
      currency { create(:currency_btc) }
    end

    trait :ltc do
      currency { create(:currency_ltc) }
    end    
  end
end