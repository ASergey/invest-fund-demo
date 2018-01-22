require 'test_helper'

class FundOperationValidatorTest < ActiveSupport::TestCase
  test 'subject error' do
    operation = build(:fund_operation, instrument: create(:instrument), investor: create(:user_investor))
    assert_not operation.save
    assert_equal I18n.t('validations.operation_subject_error'), operation.errors[:investor].first
    assert_equal I18n.t('validations.operation_subject_error'), operation.errors[:instrument].first
  end

  test 'investor role required' do
    operation = build(:fund_operation, investor: create(:user))
    assert_not operation.save
    assert_equal I18n.t('validations.investor_role_required'), operation.errors[:investor].first
  end

  test 'operation subject required' do
    investment = build(:fund_operation, investor: nil)
    payout     = build(:fund_operation, :payout, investor: nil)

    assert_not investment.save
    assert_not payout.save

    assert_equal I18n.t('validations.operation_subject_required'), investment.errors[:operation_type].first
    assert_equal I18n.t('validations.operation_subject_required'), payout.errors[:operation_type].first
  end

  test 'fees investor required' do
    management_fee = build(:operation_management_fee, investor: nil)
    interest_fee   = build(:operation_interest_fee, investor: nil)

    assert_not management_fee.save
    assert_not interest_fee.save

    assert_equal I18n.t('validations.fees_investor_required'), management_fee.errors[:investor].first
    assert_equal I18n.t('validations.fees_investor_required'), interest_fee.errors[:investor].first
  end

  test 'investor wallets required' do
  end

  test 'investor KYC required' do
  end
end
