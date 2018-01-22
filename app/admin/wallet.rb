ActiveAdmin.register Wallet do
  config.batch_actions = false

  menu parent: I18n.t('admin.fund.menu_title')

  permit_params :id, :name, :address, :currency_id
  filter        :currency

  collection_action :wallets_by_currency, method: :get

  index title: I18n.t('admin.wallet.page_title') do
    id_column
    column :name
    column :currency
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs I18n.t('admin.wallet.form_title') do
      f.input :name
      f.input :address
      f.input :currency, as: :select2, collection: Currency.select_options
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :address
      row :currency
      row :created_at
      row :updated_at
    end
  end

  controller do
    def scoped_collection
      return Wallet.fund_wallets
    end

    def wallets_by_currency
      return ajax_error(I18n.t('admin.wallet.currency_id_required')) if params[:currency_id].blank?

      wallets = Wallet.fund_wallets.where(currency_id: params[:currency_id])

      result = []
      wallets.each do |wallet|
        result << { id: wallet.id, text: wallet.name + ' - ' + wallet.currency.symbol }
      end
      ajax_ok({ wallets:  result})
    end    
  end
end
