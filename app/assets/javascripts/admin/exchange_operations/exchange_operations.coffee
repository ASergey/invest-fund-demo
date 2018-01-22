$(document).on 'ready page:load turbolinks:load', ->
  return unless $(
    '.edit.admin_exchange_operations, .new.admin_exchange_operations, .create.admin_exchange_operations, .update.admin_exchange_operations'
  ).length > 0

  init_wallets = (element, wallets)->
    $(element).html('')
    $(element).select2
      allowClear: true,
      placeholder: 'Select the wallet',
      data: wallets,
      cache: false,
      formatInputTooShort: () ->
        return 'Select the wallet'
    $(element).prepend('<option value=""></option>')
    return

  get_wallets = (currency_id, wallet_element)->
    return unless currency_id? && currency_id != ''
    $.ajax
      url: gon.wallets_url,
      data: { currency_id: currency_id }
      dataType: 'json',
      success: (response)->
        init_wallets(wallet_element, response.wallets)
      error: (response)->
        console.log response.responseJSON.common if response.responseJSON?
    return

  calculate_result =->
    unless $('#exchange_operation_from_currency_id').val() && $('#exchange_operation_to_currency_id').val() && $('#exchange_operation_amount').val()
      $('#exchange_operation_result_amount').val('')
      $('#exchange_operation_rate').val('')
      return false

    $.ajax
      url: gon.fetch_rate_url,
      data: {
        currency_id: $('#exchange_operation_from_currency_id').val(),
        to_currency_id: $('#exchange_operation_to_currency_id').val()
      }
      dataType: 'json',
      success: (response)->
        if response['rate']?
          $('#exchange_operation_rate').val response['rate']
          $('#exchange_operation_result_amount').val(
            response['rate'] * $('#exchange_operation_amount').val()
          )
      error: (response)->
        console.log response.responseJSON.common if response.responseJSON?
    return

  $('#exchange_operation_from_currency_id').on 'change, change.select2', (e) ->
    get_wallets($(this).val(), $('#exchange_operation_fund_wallet_from_id').get 0)
    return

  $('#exchange_operation_to_currency_id').on 'change, change.select2', (e) ->
    get_wallets($(this).val(), $('#exchange_operation_fund_wallet_to_id').get 0)
    return

  $('#exchange_operation_from_currency_id, #exchange_operation_to_currency_id, #exchange_operation_amount').on 'change, change.select2', (e) ->
    calculate_result()
    return