FactoryGirl.define do
  factory :investor_report do
    user
    currency
    amount 1_000.0
    capitalization 1_500.0
    daily_revenue 0.5
    daily_profit 10.0
    report_date 1.day.ago

    trait :usd do
      currency { create(:currency_usd) }
    end

    trait :btc do
      amount 10.0
      currency { create(:currency_btc) }
    end

    trait :ltc do
      amount 100.0
      currency { create(:currency_ltc) }
    end
  end
end
