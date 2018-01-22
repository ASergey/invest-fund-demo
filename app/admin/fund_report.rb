ActiveAdmin.register FundReport do
  menu parent: I18n.t('admin.fund.menu_title')
  
  config.sort_order = 'report_date_desc'

  filter :report_date
  actions :index, :show

  index do
    id_column
    column :total_invested { |f| number_format(f.total_invested) }
    column :capitalization { |f| number_format(f.capitalization) }
    column :daily_invested { |r| number_format(r.daily_invested) }
    column :total_fees { |r| number_format(r.total_fees) }
    column :currency
    column :report_date
  end
end
