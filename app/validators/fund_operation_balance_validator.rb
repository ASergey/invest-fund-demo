class FundOperationBalanceValidator < ActiveModel::Validator
  def validate(record)
    result = Services::CalcBalances::Fund.new(record).call(false) if record.investor.present?
    begin
      result = Services::CalcBalances::Instrument.new(record).call(false) if record.instrument.present?
    rescue StandardError => e
      return record.errors[:currency] << (options[:message] || e.message)
    end
    return if result.blank?
    if result[:fund_balance_amount].negative?
      record.errors[:operation_type] << (options[:message] || 
        I18n.t('validations.operation.insufficient_funds', amount: record.amount, currency: record.currency.symbol))
    end
    if record.instrument.present? && result[:subject_balance_amount].negative?
      record.errors[:operation_type] << (options[:message] || 
        I18n.t('validations.operation.instrument_insufficient_funds', instrument: record.instrument.name, amount: record.amount, currency: record.currency.symbol))
    end
  end
end
