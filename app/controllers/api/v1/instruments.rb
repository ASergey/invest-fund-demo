class API::V1::Instruments < Grape::API
  include API::V1::Defaults

  resource :instruments do
    desc I18n.t('api.instrument.listing')
    get do
      present(Instrument.all, with: API::V1::Entities::Instrument)
    end

    desc I18n.t('api.instrument.get')
    params do
      requires :instrument_id, type: String, desc: I18n.t('api.instrument.id_desc') # "ID of the instrument"
    end
    route_param :instrument_id do
      get do
        present(Instrument.find(api_params[:instrument_id]), with: API::V1::Entities::Instrument)
      end

      resource :instrument_balances do
        desc I18n.t('api.instrument.balance.listing')
        get do
          present(InstrumentBalance.by_instrument(api_params[:instrument_id]), with: API::V1::Entities::InstrumentBalance)
        end
      end
    end
  end
end
