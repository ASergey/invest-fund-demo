ActiveAdmin.register InstrumentReport do
  config.batch_actions = false
  config.sort_order    = 'report_date_desc'

  belongs_to      :instrument
  navigation_menu :instrument
  actions         :index, :show

  filter :currency
  filter :report_date

  index do
    id_column
    column :instrument
    column I18n.t('admin.instrument.balance.amount'), :amount
    column I18n.t('admin.instrument.balance.total_balance') do |report|
      report.total_balance
    end
    column :currency
    column I18n.t('admin.instrument.balance.hash_balance') do |report|
      if report.instrument_hash_reports.count > 0
        table_for report.instrument_hash_reports do
          column :hash_code
          column :hash_amount
          column :hash_rate
        end
      end
    end if %w[hashnest bixin].include?(instrument.instrument_type)
    column :report_date
    actions
  end

  show do
    attributes_table do
      row :instrument
      row I18n.t('admin.instrument.balance.amount') do |report|
        report.amount
      end
      row I18n.t('admin.instrument.balance.total_balance') do |report|
        report.total_balance
      end
      row :currency
      row I18n.t('admin.instrument.balance.hash_balance') do |report|
        if report.instrument_hash_reports.count > 0
          table_for report.instrument_hash_reports do
            column :hash_code
            column :hash_amount
            column :hash_rate
          end
        end
      end if %w[hashnest bixin].include?(instrument.instrument_type)
      row :report_date
    end
  end
end
