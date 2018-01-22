ActiveAdmin.register InvestorReport do
  config.batch_actions = false
  config.sort_order    = 'report_date_desc'

  belongs_to :user

  actions :index, :show
  filter  :user, collection: -> { User.investors_selector }
  filter  :report_date

  index do
    id_column
    column I18n.t('admin.report.investor'), :user
    column I18n.t('admin.report.amount'), :amount { |r| number_format(r.amount) }
    column :daily_revenue { |r| number_format(r.daily_revenue) }
    column :capitalization { |r| number_format(r.capitalization) }
    column :daily_profit { |r| number_format(r.daily_profit) }
    column :currency { |r| r.currency.symbol }
    column :report_date
    actions
  end

  show do
    attributes_table do
      row I18n.t('admin.report.investor') do |report|
        report.user
      end
      row I18n.t('admin.report.amount') do |report|
        number_format(report.amount)
      end
      row :daily_revenue { |r| number_format(r.daily_revenue) }
      row :capitalization { |r| number_format(r.capitalization) }
      row :daily_profit { |r| number_format(r.daily_profit) }
      row :currency
      row :report_date
    end
  end
end
