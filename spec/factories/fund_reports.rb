FactoryGirl.define do
  factory :fund_report do
    total_invested 10_000.0
    capitalization 20_000.0
    daily_invested 0.0
    total_fees 0.0
    report_date 1.day.ago
    currency

    trait :usd do
      currency { create(:currency_usd) }
    end
  end

end