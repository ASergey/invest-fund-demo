FactoryGirl.define do
  factory :instrument_report do
    currency
    instrument
    amount 100.0
    report_date 1.day.ago

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

    factory :hashnest_ltc_report, parent: :instrument_report, traits: %i[ltc] do
      amount 10.0
      after(:create) do |report|
        report.instrument_hash_reports =[create(:instrument_hash_balance, :hashnest_antl3, instrument_report: report)]
      end
    end

    factory :hashnest_btc_report, parent: :instrument_report, traits: %i[btc] do
      amount 0.1
      after(:create) do |report|
        report.instrument_hash_reports = [
          create(:instrument_hash_report, :hashnest_ants7, instrument_report: report),
          create(:instrument_hash_report, :hashnest_ants9, instrument_report: report)
        ]
      end
    end
  end
end
