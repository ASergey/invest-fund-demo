class FundOperation < ApplicationRecord
  include DefaultCurrencyExchangeConcern
  include ConditionalValidations
  extend Enumerize

  TYPE_INVESTMENT     = :investment
  TYPE_PAYOUT         = :payout
  TYPE_INTEREST_FEE   = :interest_fee
  TYPE_MANAGEMENT_FEE = :management_fee
  TYPE_EXCHANGE       = :exchange

  STATUS_CANCELED = :canceled
  STATUS_DONE     = :done
  STATUS_PENDING  = :pending

  RESOURCE_TYPE_WALLET       = 'wallet'.freeze
  RESOURCE_TYPE_BANK_ACCOUNT = 'bank_account'.freeze

  FILTER_INVESTORS   = 'investors_only'.freeze
  FILTER_INSTRUMENTS = 'instruments_only'.freeze

  around_save :calc_balances, unless: :skip_calc_balances?

  enumerize  :operation_type, in: %i[investment payout interest_fee management_fee exchange], default: :investment
  enumerize  :status, in: %i[done pending canceled], default: :pending, scope: true

  attr_accessor :payment_resource_type, :skip_calc_balances

  belongs_to :currency, optional: true
  belongs_to :instrument, optional: true
  belongs_to :user, -> { with_deleted }
  belongs_to :investor, -> { with_deleted }, class_name: 'User', optional: true
  belongs_to :wallet, optional: true
  belongs_to :kyc_document, optional: true
  belongs_to :fund_wallet_from, class_name: 'Wallet', foreign_key: 'fund_wallet_from_id', optional: true
  belongs_to :fund_wallet_to, class_name: 'Wallet', foreign_key: 'fund_wallet_to_id', optional: true

  validates :user, :amount, :currency, :operation_type, :status, :operation_date, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :operation_type, inclusion: { in: FundOperation.operation_type.values }
  validates :status, inclusion: { in: FundOperation.status.values }
  validates :currency, inclusion: { in: proc { Currency.all } }
  validates :notes, length: { maximum: 1000 }, allow_blank: true
  validates :investor, allow_nil: true, presence: true
  validates :instrument, allow_nil: true, presence: true
  # validates :fund_wallet_from, presence: true, if: proc{ |operation| operation.fund_wallet_to.blank?  }
  # validates :fund_wallet_to, presence: true, if: proc{ |operation| operation.fund_wallet_from.blank? }
  validates_date :operation_date, allow_blank: false, on_or_before: -> { Date.current }
  validates_with FundOperationValidator
  validates_with InvestorPaymentValidator
  validates_with FundOperationBalanceValidator, unless: :validate_if_no_balance?
  validates_with FundOperationWalletValidator
  acts_as_paranoid

  scope :by_investor,              ->(investor_id)   { where(investor_id: investor_id) }
  scope :by_instrument,            ->(instrument_id) { where(instrument_id: instrument_id) }
  scope :payouts_done,             ->                { where(operation_type: TYPE_PAYOUT, status: STATUS_DONE) }
  scope :investments_done,         ->                { where(operation_type: TYPE_INVESTMENT, status: STATUS_DONE) }
  scope :investors_only,           ->                { where.not(investor_id: nil) }
  scope :instruments_only,         ->                { where.not(instrument_id: nil) }
  scope :investor_investment_done, ->(investor_id)   { by_investor(investor_id).investments_done }
  scope :investor_payout_done,     ->(investor_id)   { by_investor(investor_id).payouts_done }
  scope :fees_done,                ->                {
    where(operation_type: [TYPE_MANAGEMENT_FEE, TYPE_INTEREST_FEE], status: STATUS_DONE)
  }
  scope :by_date,                  ->(date)          { where(operation_date: date) }
  scope :before_date,              ->(date)          { where('operation_date <= ?', date).order(operation_date: :desc) }

  def self.operation_subject(filter = nil)
    return if filter.blank?
    return investors_only if filter == FILTER_INVESTORS
    return instruments_only if filter == FILTER_INSTRUMENTS
  end

  def self.ransackable_scopes(*)
    %i[operation_subject]
  end

  def skip_calc_balances?
    skip_calc_balances.present?
  end

  def made_done?
    return status.done? && status_change.first != STATUS_DONE.to_s if changes.include?('status')
    false
  end

  def made_undone?
    return !status.done? && status_change.first == STATUS_DONE.to_s if changes.include?('status')
    false
  end

  def belongs_to_investor?
    investor.present? && investor.investor?
  end

  # deprecated due to operation done changes restriction
  def any_reports_changes?
    return status.done? && operation_date < Date.current if new_record?
    return status.done? && changes.include?('operation_date') unless changes.include?('status')
    (made_done? || made_undone?) && operation_date < Date.current
  end

  def calc_balances
    return yield unless made_done? || made_undone?

    FundOperation.transaction do
      Services::CalcBalances::Fund.new(self).call if investor.present?
      Services::CalcBalances::Instrument.new(self).call if instrument.present?

      if operation_date < Date.current && (investor.present? || instrument.present?)
        Services::CalcBalances::CalcFundReport.new(self).call
        Services::CalcBalances::CalcInstrumentReport.new(self).call if instrument.present?

        FundReportJob.perform_later(operation_date.to_s)
      end
      # save operation
      yield
    end
  end

  def self.operation_statuses
    return FundOperation.status.options if User.current_user.ability.can?(:approve_operation, FundOperation)
    FundOperation.status.options(except: STATUS_DONE)
  end

  def self.operation_types
    FundOperation.operation_type.options(except: [TYPE_INTEREST_FEE, TYPE_EXCHANGE])
  end

  def self.filter_subject_select
    [
      [FILTER_INVESTORS.humanize, FILTER_INVESTORS],
      [FILTER_INSTRUMENTS.humanize, FILTER_INSTRUMENTS]
    ]
  end

  def self.daily_invested(date = 1.day.ago.to_date)
    default_currency = Currency.default
    invested_grouped = group_amount_with_rates.investments_done.investors_only.by_date(date)
    invested_grouped.map(&(proc { |row| FundOperation.convert_by_date_rate(row, default_currency) })).sum.to_f
  end

  def self.daily_fees(date = 1.day.ago.to_date)
    default_currency = Currency.default
    total_fees = group_amount_with_rates.fees_done.by_date(date)
    total_fees.map(&(proc { |row| FundOperation.convert_by_date_rate(row, default_currency) })).sum
  end

  def self.investor_investment_before(investor_id, date)
    investor_investment_done(investor_id).before_date(date)
  end

  def self.investor_investment_before?(investor_id, date)
    investor_investment_before(investor_id, date)
  end

  def self.total_invested(date = 1.day.ago.to_date)
    default_currency = Currency.default

    # TODO: maybe make one request with all operation types and then make calculations with rails
    invested_grouped = group_amount_with_rates.investments_done.investors_only.before_date(date)
    total_invested   = invested_grouped.map(
      &(proc { |row| FundOperation.convert_by_date_rate(row, default_currency) })
    ).sum

    paid_out_grouped = group_amount_with_rates.payouts_done.investors_only.before_date(date)
    total_paid_out   = paid_out_grouped.map(
      &(proc { |row| FundOperation.convert_by_date_rate(row, default_currency) })
    ).sum

    fees_grouped = group_amount_with_rates.fees_done.investors_only.before_date(date)
    total_fees   = fees_grouped.map(&(proc { |row| FundOperation.convert_by_date_rate(row, default_currency) })).sum

    result = total_invested - total_paid_out - total_fees
    result.negative? ? 0.0 : result
  end

  def self.investor_total_invested(investor_id, date = 1.day.ago.to_date)
    default_currency = Currency.default
    invested_grouped = group_amount_with_rates.investor_investment_before(investor_id, date)
    total_invested = invested_grouped.map(
      &(proc { |row| FundOperation.convert_by_date_rate(row, default_currency) })
    ).sum

    paid_out_grouped = group_amount_with_rates.investor_payout_done(investor_id).before_date(date)
    total_paid_out   = paid_out_grouped.map(
      &(proc { |row| FundOperation.convert_by_date_rate(row, default_currency) })
    ).sum

    fees_grouped = group_amount_with_rates.fees_done.investors_only.before_date(date)
    total_fees   = fees_grouped.map(&(proc { |row| FundOperation.convert_by_date_rate(row, default_currency) })).sum

    result = total_invested - total_paid_out - total_fees
    result.negative? ? 0.0 : result
  end

  def self.group_amount_with_rates
    select('SUM(fund_operations.amount) as amount, exchange_rates.rate, fund_operations.currency_id')
      .joins(
        'LEFT OUTER JOIN exchange_rates
          ON fund_operations.currency_id = exchange_rates.currency_id
          AND exchange_rates.created_at = fund_operations.operation_date'
      ).joins(
        'LEFT OUTER JOIN currencies
          ON exchange_rates.currency_id = currencies.id
          AND currencies.default IS TRUE'
      ).group('fund_operations.currency_id, fund_operations.operation_date, exchange_rates.rate')
  end

  def self.convert_by_date_rate(row, default_currency)
    return row.amount if default_currency.id == row.currency_id
    row.amount * row.rate
  end
end
