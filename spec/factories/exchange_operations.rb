FactoryGirl.define do
  factory :exchange_operation do
    user
    exchange_rate
    from_currency    { create(:currency) }
    fund_wallet_from { create(:wallet) }
    to_currency      { create(:currency) }
    fund_wallet_to   { create(:wallet) }
    amount 10.0

    # after(:create) do |operation|
    #   operation.exchange_rate = create(
    #     :exchange_rate,
    #     from_currency: operation.from_currency,
    #     to_currency: operation.to_currency
    #   )
    # end
  end
end
