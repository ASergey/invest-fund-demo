FactoryGirl.define do
  factory :instrument_hash_balance do
    instrument_balance
    sequence(:hash_code)  { |n| "hash_code_#{n}" }
    hash_amount 10
    hash_rate   0.5

    trait :hashnest_antl3 do
      hash_code   'antl3'
      hash_amount 100
      hash_rate   0.5
    end

    trait :hashnest_ants7 do
      hash_code   'ants7'
      hash_amount 100
      hash_rate   0.1
    end

    trait :hashnest_ants9 do
      hash_code   'ants9'
      hash_amount 100
      hash_rate   0.2
    end
  end
end
