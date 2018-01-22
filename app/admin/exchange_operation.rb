ActiveAdmin.register ExchangeOperation do
  menu parent: I18n.t('admin.exchange.menu_title')

  permit_params :amount, :from_currency_id, :to_currency_id, :fund_wallet_from_id, :fund_wallet_to_id

  actions       :index, :show, :new, :create, :destroy
  before_action :init_gon_vars, only: %i[new create]

  config.batch_actions = false
  config.sort_order    = 'created_at_desc'

  filter :from_currency
  filter :to_currency
  filter :created_at

  index do
    id_column
    column :amount
    column :from_currency
    column :result_amount
    column :to_currency
    column :exchange_rate { |op| op.exchange_rate.rate }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :amount
      row :from_currency
      row :fund_wallet_from
      row :result_amount
      row :to_currency
      row :fund_wallet_to
      row :exchange_rate { |op| op.exchange_rate.rate }

      row :user
      row :created_at
    end
  end

  form do |f|
    f.inputs do
      f.semantic_errors  *f.object.errors.keys
      f.input :from_currency, as: :select2, collection: Currency.select_options
      f.input :fund_wallet_from, as: :select2, collection: Wallet.fund_wallets_options
      f.input :to_currency, as: :select2, collection: Currency.select_options
      f.input :fund_wallet_to, as: :select2, collection: Wallet.fund_wallets_options
      f.input :amount, input_html: { value: number_format(f.object.amount) }
      f.input :rate, input_html: { readonly: true, placeholder: I18n.t('admin.exchange.operation_rate_placeholder') }
      f.input :result_amount, input_html: {
        readonly: true,
        placeholder: I18n.t('admin.exchange.operation_result_amount_placeholder')
      }
    end
    f.actions
  end

  controller do
    def init_gon_vars
      gon.push(
        wallets_url:    wallets_by_currency_admin_wallets_path,
        fetch_rate_url: fetch_rate_admin_exchange_rates_path
      )
    end

    def build_new_resource
      resource = super
      if resource.from_currency.present? && resource.to_currency.present?
        exchange_rate = ExchangeRate.rate_to_currency(resource.from_currency.id, resource.to_currency.id)
        resource.assign_attributes(
          exchange_rate: exchange_rate,
          user_id: current_user.id
        )
      end
      resource
    end
  end
end
