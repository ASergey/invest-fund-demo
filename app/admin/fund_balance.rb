ActiveAdmin.register FundBalance do
  menu parent: I18n.t('admin.fund.menu_title')

  config.batch_actions = false
  config.filters       = false

  permit_params :id, :currency_id, :amount
  actions       :all, except: %i[destroy show]

  index do
    column :currency
    column :amount { |b| number_format(b.amount) }
    column :created_at
    column :updated_at
    actions
  end

  sidebar I18n.t('admin.fund_balance.notes') do
    text_node I18n.t('admin.fund_balance.sidebar_text')
    br
    h5(I18n.t('admin.fund_balance.total_capitalization'), class: 'panel-title')
    span number_format(FundBalance.total_capitalization)
    span Currency.default.symbol
  end
end
