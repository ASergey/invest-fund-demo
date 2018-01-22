FactoryGirl.define do
  factory :instrument_balance do
    instrument
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

    factory :hashnest_ltc_balance, parent: :instrument_balance, traits: %i[ltc] do
      amount 10.0
      after(:create) do |balance|
        balance.instrument_hash_balances =[create(:instrument_hash_balance, :hashnest_antl3)]
      end
    end

    factory :hashnest_btc_balance, parent: :instrument_balance, traits: %i[btc] do
      amount 0.1
      after(:create) do |balance|
        balance.instrument_hash_balances = [
          create(:instrument_hash_balance, :hashnest_ants7, instrument_balance: balance),
          create(:instrument_hash_balance, :hashnest_ants9, instrument_balance: balance)
        ]
      end
    end
  end
end
