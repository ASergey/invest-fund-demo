class API::V1::Currencies < Grape::API
  include API::V1::Defaults

  resource :currencies do
    desc I18n.t('api.currency.listing')
    get do
      present(Currency.all, with: API::V1::Entities::Currency)
    end

    desc I18n.t('api.currency.get')
    params do
      requires :currency_id, type: String, desc: I18n.t('api.currency.id_desc')
    end
    get ':currency_id' do
      present(Currency.find(api_params[:currency_id]), with: API::V1::Entities::Currency)
    end
  end
end
