class FundOperationValidator < ActiveModel::Validator
  def validate(record)
    must_be_undone?(record)
    subject_required?(record)
    wrong_subject?(record)
    fees_investor_required?(record)
    investor_role_required?(record)
  end

  private

  def subject_required?(record)
    if %w[investment payout].include?(record.operation_type) && (record.investor.blank? && record.instrument.blank?)
      record.errors[:operation_type] << (options[:message] || I18n.t('validations.operation_subject_required'))
    end
  end

  def wrong_subject?(record)
    if record.investor.present? && record.instrument.present?
      error_message = (options[:message] || I18n.t('validations.operation_subject_error'))
      record.errors[:investor] << error_message
      record.errors[:instrument] << error_message
    end
  end

  def fees_investor_required?(record)
    if %w[interest_fee management_fee].include?(record.operation_type) && record.investor.blank?
      record.errors[:investor] << (options[:message] || I18n.t('validations.fees_investor_required'))
    end
  end

  def investor_role_required?(record)
    if record.instrument.blank? && (record.investor.blank? || !record.investor.investor?)
      record.errors[:investor] << (options[:message] || I18n.t('validations.investor_role_required'))
    end
  end

  def must_be_undone?(record)
    if record.status.done? && record.changes.present? && !record.changes.include?('status')
      record.errors[:status] << (options[:message] || I18n.t('validations.operation_must_be_undone'))
    end
  end
end
