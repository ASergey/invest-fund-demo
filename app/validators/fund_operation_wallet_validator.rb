class FundOperationWalletValidator < ActiveModel::Validator
  def validate(record)
    return if record.currency.blank? || (record.fund_wallet_from.blank? && record.fund_wallet_to.blank?)
    if record.fund_wallet_from.present? && record.fund_wallet_from.currency.id != record.currency.id
      record.errors[:fund_wallet_from] << I18n.t('validations.operation.wallet_wrong_currency', 
                                                 wallet_currency: record.fund_wallet_from.currency.symbol,
                                                 currency: record.currency.symbol
                                                )
    end
    if record.fund_wallet_to.present? && record.fund_wallet_to.currency.id != record.currency.id
      record.errors[:fund_wallet_to] << I18n.t('validations.operation.wallet_wrong_currency',
                                                 wallet_currency: record.fund_wallet_to.currency.symbol,
                                                 currency: record.currency.symbol
                                              )
    end
  end
end
