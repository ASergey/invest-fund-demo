class API::V1::InstrumentBalances < Grape::API
  include API::V1::Defaults

  helpers InstrumentApiHelper

  resource :instrument_balances do
    desc I18n.t('api.instrument.balance.get')
    params do
      requires :instrument_balance_id, type: String, desc: I18n.t('api.instrument.balance.id_desc')
    end
    get ':instrument_balance_id' do
      present(InstrumentBalance.find(api_params[:instrument_balance_id]), with: API::V1::Entities::InstrumentBalance)
    end

    desc I18n.t('api.instrument.balance.update')
    params do
      use :update_instrument_balance
    end
    put ':instrument_balance_id' do
      instrument_balance = InstrumentBalance.find(api_params[:instrument_balance_id])
      fail ActiveRecord::RecordNotFound, I18n.t('api.instrument.balance.not_found') if instrument_balance.nil?

      balance_params = instrument_balance_params
      hash_balances  = balance_params.delete(:instrument_hash_balances) || []

      instrument_balance.assign_attributes(balance_params)
      hash_balances.each do |hash_balance|
        if hash_balance[:id].present?
          balance = InstrumentHashBalance.find_by!(id: hash_balance[:id], instrument_balance_id: instrument_balance[:id])
        else
          balance = InstrumentHashBalance.new(instrument_balance: instrument_balance)
        end
        balance.assign_attributes(hash_balance)
        instrument_balance.instrument_hash_balances << balance
      end
      fail ApiErrors::ValidationError.new(I18n.t('api.instrument.balance.validation_fail'), instrument_balance.errors.messages) unless instrument_balance.save

      present({ instrument_balance: instrument_balance }, with: API::V1::Entities::InstrumentBalanceUpdateSuccess)
    end
  end
end
