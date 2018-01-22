FactoryGirl.define do
  factory :investor_monthly_report do
    user
    currency
    dividend_amount 1_000.0
    management_fee 25.0
    carried_interest_fee 25.0
    payout_amount 950.0
    report_date 1.month.ago.end_of_month
  end
end
