module InstrumentApiHelper
  extend Grape::API::Helpers

  params :update_instrument_balance do
    requires :instrument_balance_id, type: Integer
    requires :amount, type: Float
    optional :currency_id, type: Integer
    use :instrument_hash_balances
  end

  params :instrument_hash_balances do
    optional :instrument_hash_balances, desc: 'Array of instrument hash balances.
      Hash balance required fields:<ul>
      <li>id</li>
      <li>hash_code</li>
      <li>hash_amount</li>
      <li>hash_rate</li></ul>'
  end

  def instrument_balance_params
    result = api_params
    if params[:instrument_hash_balances].is_a? String
      result[:instrument_hash_balances] = JSON.parse(params[:instrument_hash_balances])
    else
      result[:instrument_hash_balances] = params[:instrument_hash_balances]
    end
    result.delete(:instrument_balance_id)
    result.permit(:id, :amount, :currency_id, instrument_hash_balances: %i[id hash_code hash_amount hash_rate])
  end
end
