ActiveAdmin.register InvestorMonthlyReport do
  config.batch_actions = false
  config.sort_order    = 'report_date_desc'

  belongs_to :user

  actions :all, except: %i[new create edit update destroy]
  filter  :user, collection: -> { User.investors_selector }
  filter  :report_date

  index do
    id_column
    column I18n.t('admin.report.investor'), :user
    column I18n.t('admin.report.monthly_dividends'), :amount { |r| number_format(r.dividend_amount) }
    column :management_fee { |r| number_format(r.management_fee) }
    column :carried_interest_fee { |r| number_format(r.carried_interest_fee) }
    column :payout_amount { |r| number_format(r.payout_amount) }
    column :currency { |r| r.currency.symbol }
    column :report_date
    actions
  end

  show do
    attributes_table do
      row I18n.t('admin.report.investor') do |report|
        report.user
      end
      row I18n.t('admin.report.monthly_dividends') do |report|
        number_format(report.dividend_amount)
      end
      row :management_fee { |r| number_format(r.management_fee) }
      row :carried_interest_fee { |r| number_format(r.carried_interest_fee) }
      row :payout_amount { |r| number_format(r.payout_amount) }
      row :currency
      row :report_date
    end
  end
end