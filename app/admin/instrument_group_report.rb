ActiveAdmin.register InstrumentReport, as: 'Instrument Group Reports' do
  menu parent: I18n.t('admin.instrument.menu_title')

  config.batch_actions = false
  config.sort_order    = 'report_date_desc'

  actions :index
  filter  :currency
  filter  :instrument_group
  filter  :report_date

  index title: I18n.t('admin.instrument.groups.report_title') do
    column :group_name
    column I18n.t('admin.instrument.groups.amount_title'), :sum_amount
    column I18n.t('admin.fund_balance.currency'), :symbol
    column :report_date
  end

  controller do
    def scoped_collection
      InstrumentReport.grouped_daily_reports
    end
  end
end
