class InvestorWallet < Wallet
  belongs_to :user

  validates :user, presence: true
  validates :address, uniqueness: {
              case_sensitive: false,
              scope: %i[user_id currency_id],
              message: I18n.t('validations.user_unique_wallet')
            }
  validates :name, length: { maximum: 100 },
    uniqueness: {
      case_sensitive: false,
      scope:          :user_id,
      message:        I18n.t('validations.user_unique_wallet')
    }
end
