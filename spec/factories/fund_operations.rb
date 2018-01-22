FactoryGirl.define do
  factory :fund_operation do
    user
    investor       { create(:user_investor) }
    amount         10_000.0
    currency
    operation_type :investment
    status         FundOperation::STATUS_PENDING
    operation_date Date.current

    trait :done do
      status FundOperation::STATUS_DONE
    end

    trait :canceled do
      status FundOperation::STATUS_CANCELED
    end

    trait :payout do
      operation_type :payout
    end

    trait :interest_fee do
      operation_type :interest_fee
    end

    trait :management_fee do
      operation_type :management_fee
    end

    trait :exchange do
      operation_type :exchange
    end

    trait :instrument_operation do
      investor nil
      instrument
    end

    trait :wallet_payment do
      payment_resource_type FundOperation::RESOURCE_TYPE_WALLET
    end

    trait :bank_payment do
      payment_resource_type FundOperation::RESOURCE_TYPE_BANK_ACCOUNT
    end

    factory :operation_investor_payout,       traits: [:payout]
    factory :operation_interest_fee,          traits: [:interest_fee]
    factory :operation_management_fee,        traits: [:management_fee]
    factory :operation_instrument_investment, traits: [:instrument_operation]
    factory :operation_instrument_payout,     traits: [:instrument_operation, :payout]

    # fund_wallet_from
  end
end
