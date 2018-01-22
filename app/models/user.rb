class User < ApplicationRecord
  include ConditionalValidations

  rolify
  acts_as_paranoid
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :lockable, :rememberable, :trackable, authentication_keys: [:email]

  scope :investor, -> { joins(:roles).where('roles.name' => RoleName::INVESTOR) }

  has_many :fund_operations, dependent: :restrict_with_error
  has_one  :kyc_document, dependent: :destroy
  has_many :investor_wallets, dependent: :destroy
  has_many :investor_reports, dependent: :restrict_with_error
  has_many :investor_monthly_reports, dependent: :restrict_with_error
  has_many :exchange_operations

  accepts_nested_attributes_for :kyc_document, allow_destroy: true
  accepts_nested_attributes_for :investor_wallets, allow_destroy: true

  validates :name, presence: true, length: { minimum: 2 }, unless: :validate_if_no_name?
  validates :email, presence: true, unless: :validate_if_no_email?
  validates :email, uniqueness: { case_sensitive: false, scope: :deleted_at }, allow_blank: true, unless: :validate_if_no_email?
  validates :email, format: { with: Devise.email_regexp }, allow_blank: true, unless: :validate_if_no_email?
  validates :password, presence: true, on: :create, unless: :validate_if_no_password?
  validates :password, length: { within: Devise.password_length }, allow_blank: true, unless: :validate_if_no_password?
  validates :password, confirmation: true, unless: :validate_if_no_password?
  validates :phone, presence: true, if: :investor?, unless: :validate_if_no_phone?
  validates :reinvest, exclusion: { in: [nil] }, inclusion: { in: [true, false] }, if: :investor?

  def ability
    @ability ||= Ability.new(self)
  end

  def investor?
    has_role?(RoleName::INVESTOR)
  end

  def self.investors_selector
    investor.select(:id, :name, :email).collect { |investor| [investor.name + ' - ' + investor.email, investor.id] }
  end

  def self.current_user=(user)
    RequestStore.store[:current_user] = user
  end

  def self.current_user
    RequestStore.store[:current_user]
  end

  def first_investment
    return nil unless investor?
    FundOperation.investor_investment_done(id).order('operation_date asc').first
  end

  def total_invested
    return nil unless investor?
    FundOperation.investor_investment_done(id).group(:currency).sum(:amount)
  end

  def total_paid_out
    return nil unless investor?
    FundOperation.investor_payout_done(id).group(:currency).sum(:amount)
  end
end
