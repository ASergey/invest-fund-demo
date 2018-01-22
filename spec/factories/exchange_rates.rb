FactoryGirl.define do
  factory :exchange_rate do
    from_currency { create(:currency) }
    to_currency   { create(:currency) }
    rate 0.5
  end
end