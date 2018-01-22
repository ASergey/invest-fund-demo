# Create roles
Role.create([
  { name: RoleName::ADMIN.to_s },
  { name: RoleName::ADMIN_READ_ONLY.to_s },
  { name: RoleName::MANAGER.to_s },
  { name: RoleName::FINANCIAL_MANAGER.to_s },
  { name: RoleName::INVESTOR.to_s }
])

# Create admin & investors
admin_developer = User.create!(
  name: 'Developer',
  email: 'demo@admin.com',
  password: '12345678',
  roles: [Role.find_by(name: RoleName::ADMIN.to_s)]
)

test_user_1 = User.create!(
  name: 'test_user_1',
  roles: [Role.find_by(name: RoleName::INVESTOR.to_s)],
  email: 'test_user_1@example.com',
  validated_scopes: %i[no_password no_email no_phone],
  is_gp: true,
  reinvest: true
)
test_user_2 = User.create!(
  name: 'test_user_2',
  roles: [Role.find_by(name: RoleName::INVESTOR.to_s)],
  email: 'test_user_2@example.com',
  validated_scopes: %i[no_password no_phone],
  is_gp: true,
  reinvest: true
)
test_user_3 = User.create!(
  name: 'test_user_3',
  roles: [Role.find_by(name: RoleName::INVESTOR.to_s)],
  email: 'test_user_3@example.com',
  validated_scopes: %i[no_password no_phone],
  is_gp: true,
  reinvest: true
)
test_user_33 = User.create!(
  name: 'test_user_33',
  roles: [Role.find_by(name: RoleName::INVESTOR.to_s)],
  email: 'test_user_33@example.com',
  validated_scopes: %i[no_password no_phone],
  is_gp: true,
  reinvest: true
)
test_user_4 = User.create!(
  name: 'User M',
  roles: [Role.find_by(name: RoleName::INVESTOR.to_s)],
  email: 'test_user_4v@example.com',
  validated_scopes: %i[no_password no_phone],
  is_gp: true,
  reinvest: true
)
test_user_5 = User.create!(
  name: 'User N',
  roles: [Role.find_by(name: RoleName::INVESTOR.to_s)],
  email: 'test_user_5@example.com',
  validated_scopes: %i[no_password no_phone],
  is_gp: true,
  reinvest: true
)
test_user_6 = User.create!(
  name: 'test_user_6',
  roles: [Role.find_by(name: RoleName::INVESTOR.to_s)],
  email: 'test_user_6@example.com',
  validated_scopes: %i[no_password no_phone],
  is_gp: true,
  reinvest: true
)

currency_usd = Currency.create!(name: 'United States dollar', symbol: 'USD', default: true)
currency_btc = Currency.create!(name: 'Bitcoin', symbol: 'BTC')
currency_ltc = Currency.create!(name: 'Litecoin', symbol: 'LTC')

operation_done = {
  status:             FundOperation::STATUS_DONE,
  operation_type:     FundOperation::TYPE_INVESTMENT,
  currency:           currency_usd,
  operation_date:     '2017-09-01',
  skip_calc_balances: true,
  user:               admin_developer
}

# values taken from August dividends excel list
FundOperation.create!(operation_done.merge({ investor: test_user_1, amount: 299603.9494 }))
FundOperation.create!(operation_done.merge({ investor: test_user_2, amount: 100148.591 }))
FundOperation.create!(operation_done.merge({ investor: test_user_3, amount: 553678.2418 }))
FundOperation.create!(operation_done.merge({ investor: test_user_33, amount: 26158.54563 }))
FundOperation.create!(operation_done.merge({ investor: test_user_4, amount: 8711.950752 }))
FundOperation.create!(operation_done.merge({ investor: test_user_5, amount: 30923.00399 }))

usd_balance_amount = 29742.09004
btc_balance_amount = 0.0
ltc_balance_amount = 0.0

last_month_end_date = (Date.current - 1.month).end_of_month # 2017-08-31

FundBalance.by_currency(currency_usd.id).update_all(amount: usd_balance_amount)
FundBalance.create!(currency: currency_btc, amount: btc_balance_amount)
FundBalance.create!(currency: currency_ltc, amount: ltc_balance_amount)
FundBalanceReport.create!([
  { currency: currency_usd, amount: usd_balance_amount, report_date: last_month_end_date },
  { currency: currency_btc, amount: btc_balance_amount, report_date: last_month_end_date },
  { currency: currency_ltc, amount: ltc_balance_amount, report_date: last_month_end_date }
])

miners_instrument   = Instrument.create!(name: 'Ordered miners')
ico_instrument      = Instrument.create!(name: 'ICO investment')
hashnest_instrument = Instrument.create!(name: 'Hashnest', instrument_type: Instrument.instrument_type.hashnest)
bixin_instrument    = Instrument.create!(name: 'Bixin', instrument_type: Instrument.instrument_type.bixin)

# Balance data was taken according to Aug 31 excel list
miner_balance_attrs = { instrument: miners_instrument, currency: currency_usd, amount: 670791.7726 }
ico_balance_attrs   = { instrument: ico_instrument, currency: currency_usd, amount: 114285.148 }

bixin_balance_attrs = {
  instrument: bixin_instrument, 
  currency: currency_btc, 
  amount: 0.18985936, 
  instrument_hash_balances_attributes: [
    {
      hash_code: '150w/t',
      hash_amount: 8,
      hash_rate: 0.0528
    },
    {
      hash_code: '300w/t',
      hash_amount: 54,
      hash_rate: 0.044
    }
  ]
}
bixin_report_attrs = {
  instrument: bixin_instrument, 
  currency: currency_btc, 
  amount: 0.18985936, 
  instrument_hash_reports_attributes: [
    {
      hash_code: '150w/t',
      hash_amount: 8,
      hash_rate: 0.0528
    },
    {
      hash_code: '300w/t',
      hash_amount: 54,
      hash_rate: 0.044
    }
  ]
}

# Hashnest balance data was taken from hashnest bot project according to Sep 17
# TODO: must be updated to current data
hashnest_btc_balance_attrs = {
  instrument: hashnest_instrument,
  currency: currency_btc,
  amount: 17.446967587,
  instrument_hash_balances_attributes: [
    {
      hash_code: 'ANTS7',
      hash_amount: 621,
      hash_rate: 0.000031617
    },
    {
      hash_code: 'ANTS9',
      hash_amount: 251405,
      hash_rate: 0.000063894
    }
  ]
}
hashnest_ltc_balance_attrs = {
  instrument: hashnest_instrument,
  currency: currency_ltc,
  amount: 3601.87676589,
  instrument_hash_balances_attributes: [
    {
      hash_code: 'ANTL3',
      hash_amount: 0,
      hash_rate: 0.270212388
    }
  ]
}

InstrumentBalance.create!([miner_balance_attrs, ico_balance_attrs])
InstrumentReport.create!([miner_balance_attrs.merge({ report_date: last_month_end_date }), ico_balance_attrs.merge({ report_date: last_month_end_date })])

InstrumentBalance.create!(hashnest_btc_balance_attrs)
InstrumentBalance.create!(hashnest_ltc_balance_attrs)
InstrumentBalance.create!(bixin_balance_attrs)

InstrumentReport.create!(bixin_report_attrs.merge({ report_date: last_month_end_date }))

# Hashnest reports
btc_hashnest_report_common = {
  instrument: hashnest_instrument,
  currency: currency_btc,
  instrument_hash_reports_attributes: [
    {
      hash_code: 'ANTS7',
      hash_amount: 621,
      hash_rate: 0.000031617
    },
    {
      hash_code: 'ANTS9',
      hash_amount: 251405,
      hash_rate: 0.000063894
    }
  ]
}
## 2017-08-31
InstrumentReport.create!(btc_hashnest_report_common.merge({ amount: 17.233952207, report_date: last_month_end_date }))
InstrumentReport.create!(
  instrument: hashnest_instrument,
  currency: currency_ltc,
  amount: 4502.87376589,
  report_date: last_month_end_date,
  instrument_hash_reports_attributes: [
    {
      hash_code: 'ANTL3',
      hash_amount: 0,
      hash_rate: 0.270212388
    }
  ]
)
InstrumentReport.create!(btc_hashnest_report_common.merge({ amount: 17.328107887, report_date: '2017-09-01' }))
InstrumentReport.create!(btc_hashnest_report_common.merge({ amount: 16.445302457, report_date: '2017-09-02' }))
InstrumentReport.create!(btc_hashnest_report_common.merge({ amount: 16.508198847, report_date: '2017-09-03' }))
InstrumentReport.create!(btc_hashnest_report_common.merge({ amount: 16.595651007, report_date: '2017-09-04' }))
InstrumentReport.create!(btc_hashnest_report_common.merge({ amount: 16.595651007, report_date: '2017-09-05' }))
InstrumentReport.create!(btc_hashnest_report_common.merge({ amount: 16.693596127, report_date: '2017-09-06' }))
InstrumentReport.create!(btc_hashnest_report_common.merge({ amount: 16.782325597, report_date: '2017-09-07' }))
InstrumentReport.create!(btc_hashnest_report_common.merge({ amount: 16.782325597, report_date: '2017-09-08' }))
InstrumentReport.create!(btc_hashnest_report_common.merge({ amount: 16.907358137, report_date: '2017-09-09' }))
InstrumentReport.create!(btc_hashnest_report_common.merge({ amount: 16.932229097, report_date: '2017-09-10' }))
InstrumentReport.create!(btc_hashnest_report_common.merge({ amount: 17.095330057, report_date: '2017-09-11' }))
InstrumentReport.create!(btc_hashnest_report_common.merge({ amount: 17.133188327, report_date: '2017-09-12' }))
InstrumentReport.create!(btc_hashnest_report_common.merge({ amount: 17.151763667, report_date: '2017-09-14' }))
InstrumentReport.create!(btc_hashnest_report_common.merge({ amount: 17.179101347, report_date: '2017-09-16' }))
InstrumentReport.create!(btc_hashnest_report_common.merge({ amount: 17.446967587, report_date: '2017-09-17' }))

# FundReport 2017-08-31
FundReport.create!(
  total_invested: 921663.268, # August 31 list from excel
  capitalization: 1263727.496,
  daily_invested: 0,
  total_fees:     0,
  currency:       currency_usd,
  report_date:    last_month_end_date
)

test_user_1_report      = { user: test_user_1, amount: 272034.6958, daily_revenue: 0.3158412876, capitalization: 399137.3195, daily_profit: 20428.96866 }
test_user_2_report = { user: test_user_2, amount: 85007.5351, daily_revenue: 0.09112766551, capitalization: 115160.5365, daily_profit: 5894.239595 }
test_user_3_report       = { user: test_user_3, amount: 496188.1971, daily_revenue: 0.5217158833, capitalization: 659306.7067, daily_profit: 33745.16838 }
test_user_33_report   = { user: test_user_33, amount: 25091.33, daily_revenue: 0.02835387919, capitalization: 35831.57674, daily_profit: 1833.960701 }
test_user_4_report   = { user: test_user_4, amount: 9896.69, daily_revenue: 0.009443093762, capitalization: 11933.49723, daily_profit: 610.7898939 }
test_user_5_report     = { user: test_user_5, amount: 33444.82, daily_revenue: 0.03351819063, capitalization: 42357.85911, daily_profit: 2167.994157 }
test_user_6_report    = { user: test_user_6, amount: 0.0, daily_revenue: 0.0, capitalization: 0.0, daily_profit: 0.0  }
InvestorReport.create!(
  [
    test_user_1_report,
    test_user_2_report,
    test_user_3_report,
    test_user_33_report,
    test_user_4_report,
    test_user_5_report,
    test_user_6_report
  ].map { |a| a.merge({ currency: currency_usd, report_date: last_month_end_date }) }
)

# Have no rates data for 2017-09-01 .. 2017-09-04
btc_to_usd_rates = [
  { from_currency: currency_btc, to_currency: currency_usd, rate: 3919.16922659259, created_at: '2017-09-20' },
  { from_currency: currency_btc, to_currency: currency_usd, rate: 4063.3647926075, created_at: '2017-09-19' },
  { from_currency: currency_btc, to_currency: currency_usd, rate: 3694.9937214909, created_at: '2017-09-18' },
  { from_currency: currency_btc, to_currency: currency_usd, rate: 3700.0862672832, created_at: '2017-09-17' },
  { from_currency: currency_btc, to_currency: currency_usd, rate: 3719.8423020813, created_at: '2017-09-16' },
  { from_currency: currency_btc, to_currency: currency_usd, rate: 3241.4399703093, created_at: '2017-09-15' },
  { from_currency: currency_btc, to_currency: currency_usd, rate: 3899.1364814963, created_at: '2017-09-14' },
  { from_currency: currency_btc, to_currency: currency_usd, rate: 4160.3880744681, created_at: '2017-09-13' },
  { from_currency: currency_btc, to_currency: currency_usd, rate: 4200.7200780729, created_at: '2017-09-12' },
  { from_currency: currency_btc, to_currency: currency_usd, rate: 4238.4284410982, created_at: '2017-09-11' },
  { from_currency: currency_btc, to_currency: currency_usd, rate: 4321.699952402,  created_at: '2017-09-10' },
  { from_currency: currency_btc, to_currency: currency_usd, rate: 4327.7819082744, created_at: '2017-09-09' },
  { from_currency: currency_btc, to_currency: currency_usd, rate: 4621.6829748067, created_at: '2017-09-08' },
  { from_currency: currency_btc, to_currency: currency_usd, rate: 4607.2118825221, created_at: '2017-09-07' },
  { from_currency: currency_btc, to_currency: currency_usd, rate: 4445.0951860852, created_at: '2017-09-06' },
  { from_currency: currency_btc, to_currency: currency_usd, rate: 4340.8024883946, created_at: '2017-09-05'},
  { from_currency: currency_btc, to_currency: currency_usd, rate: 4340.8024883946, created_at: '2017-09-04'},
  { from_currency: currency_btc, to_currency: currency_usd, rate: 4716.4, created_at: '2017-09-03'},
  { from_currency: currency_btc, to_currency: currency_usd, rate: 4716.4, created_at: '2017-09-02'},
  { from_currency: currency_btc, to_currency: currency_usd, rate: 4716.4, created_at: '2017-09-01'}
]

ltc_to_usd_rates = [
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 53.0117019428903, created_at: '2017-09-20' },
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 55.6524537043, created_at: '2017-09-19' },
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 50.3441416556, created_at: '2017-09-18' },
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 50.9413076934, created_at: '2017-09-17' },
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 51.2312026192, created_at: '2017-09-16' },
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 44.2858656576, created_at: '2017-09-15' },
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 62.0751105954, created_at: '2017-09-14' },
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 65.708534789,  created_at: '2017-09-13' },
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 67.4206961055, created_at: '2017-09-12' },
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 65.3149345984, created_at: '2017-09-11' },
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 69.8135945668, created_at: '2017-09-10' },
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 72.2215484293, created_at: '2017-09-09' },
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 79.6959199287, created_at: '2017-09-08' },
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 81.1350399425, created_at: '2017-09-07' },
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 73.2075394718, created_at: '2017-09-06' },
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 69.9141368948, created_at: '2017-09-05' },
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 69.9141368948, created_at: '2017-09-04'},
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 78.268658, created_at: '2017-09-03'},
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 78.268658, created_at: '2017-09-02'},
  { from_currency: currency_ltc, to_currency: currency_usd, rate: 78.268658, created_at: '2017-09-01'}
]

ExchangeRate.create!(btc_to_usd_rates)
ExchangeRate.create!(ltc_to_usd_rates)

Setting.management_fee       = 0.0020833333
Setting.carried_interest_fee = 0.0020833333

ApiClient.create(
  name: 'Hashnest bot',
  client_key: '729a159c902383288958cffb4567bdd4bc10c0b85d559cd888b27d92ce90454ee83cc6a42c21c05be07670a3765a86ba733e207bb507f8434a7824459b5877cf'
)