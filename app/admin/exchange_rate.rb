ActiveAdmin.register ExchangeRate do
  menu parent: I18n.t('admin.exchange.menu_title')

  actions :index

  config.batch_actions = false
  config.sort_order    = 'created_at_desc'

  filter :from_currency
  filter :to_currency
  filter :created_at

  collection_action :fetch_rate

  controller do
    def fetch_rate
      unless [params[:currency_id], params[:to_currency_id]].all?(&:present?)
        return render json: { common: I18n.t('admin.exchange.get_rate_params_error') }, status: 200
      end

      rate = ExchangeRate.rate_to_currency(params[:currency_id], params[:to_currency_id])
      return ajax_error(I18n.t('admin.exchange.rate_not_found')) if rate.blank?
      ajax_ok(rate)
    end
  end
end
