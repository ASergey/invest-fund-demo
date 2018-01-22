class InvestorPaymentValidator < ActiveModel::Validator
  def validate(record)
    return if record.investor.blank?
    if record.payment_resource_type == FundOperation::RESOURCE_TYPE_WALLET && record.investor.investor_wallets.blank?
      record.errors[:payment_resource_type] << (options[:message] || I18n.t('validations.operation_investor_wallet_required'))
    end
    return record.errors[:wallet] << (options[:message] || I18n.t('validations.operation_wallet_required')) if record.payment_resource_type == FundOperation::RESOURCE_TYPE_WALLET && record.wallet.blank?
    record.errors[:wallet] << (options[:message] || I18n.t('validations.operation.wrong_investor_wallet')) if record.payment_resource_type == FundOperation::RESOURCE_TYPE_WALLET && record.wallet.user.id != record.investor.id
    record.errors[:payment_resource_type] << (options[:message] || I18n.t('validations.operation_kyc_required')) if record.payment_resource_type == FundOperation::RESOURCE_TYPE_BANK_ACCOUNT && record.kyc_document.blank?
  end
end
