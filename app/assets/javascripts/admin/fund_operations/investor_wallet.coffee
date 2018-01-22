$(document).on 'ready page:load turbolinks:load', ->
  return unless $(
    '.edit.admin_fund_operations, .new.admin_fund_operations, .create.admin_fund_operations, .update.admin_fund_operations, ' +
    '.edit.admin_operations, .new.admin_operations, .create.admin_operations, .update.admin_operations'
  ).length > 0

  wallets = []

  init_wallets = ->
    selected_wallet = $('#fund_operation_wallet_id').val()
    $('#fund_operation_wallet_id').html('')
    $('#fund_operation_wallet_id').select2
      allowClear: true,
      placeholder: 'Select the wallet',
      data: wallets,
      cache: false,
      formatInputTooShort: () ->
        return 'Select the wallet'
    $('#fund_operation_wallet_id').prepend('<option value=""></option>')
    $('#fund_operation_wallet_id').val(selected_wallet).trigger('change.select2')
    return

  hide_wallets_input = ->
    $('#fund_operation_wallet_input').hide()

  get_investor_wallets = ->
    wallets_before = wallets
    $.ajax
      url: gon.investor_wallets_url,
      data: {id: $('#fund_operation_investor_id').val()}
      dataType: 'json',
      success: (response)->
        wallets = response.wallets
        init_wallets() if wallets.length > 0 && wallets_before != wallets
        hide_wallets_input() unless wallets.length > 0
      error: (response)->
        hide_wallets_input()
        console.log response.responseJSON.common if response.responseJSON?
    return

  switch_payment_type = (element) ->
    if $(element).val() == 'wallet'
      $('#fund_operation_wallet_input').show()
      $('#fund_operation_currency_input').hide()
      get_investor_wallets()
    else
      hide_wallets_input()
      $('#fund_operation_currency_input').show()
    return

  disable_fund_wallet_from = ->
    fund_wallet_from_el = $('#fund_operation_fund_wallet_from_id')
    fund_wallet_to_el   = $('#fund_operation_fund_wallet_to_id')
    fund_wallet_from_el.val('').prop('disabled', true).trigger('change.select2')
    $('#fund_operation_fund_wallet_from_input').hide()
    $('#fund_operation_fund_wallet_to_input').show()
    fund_wallet_to_el.prop('disabled', false).trigger('change.select2') unless fund_wallet_to_el.val() and fund_wallet_to_el.prop('disabled')

  disable_fund_wallet_to = ->
    fund_wallet_from_el = $('#fund_operation_fund_wallet_from_id')
    fund_wallet_to_el   = $('#fund_operation_fund_wallet_to_id')
    fund_wallet_to_el.val('').prop('disabled', true).trigger('change.select2')
    $('#fund_operation_fund_wallet_to_input').hide()
    $('#fund_operation_fund_wallet_from_input').show()
    fund_wallet_from_el.prop('disabled', false).trigger('change.select2') unless fund_wallet_from_el.val() and fund_wallet_from_el.prop('disabled')

  toggle_fund_wallet = ->
    investor_val   = $('#fund_operation_investor_id').val()
    operation_type = $('#fund_operation_operation_type').val()

    if operation_type is 'payout'
      if investor_val then disable_fund_wallet_to() else disable_fund_wallet_from()
    else
      if investor_val then disable_fund_wallet_from() else disable_fund_wallet_to()

  $('#fund_operation_investor_id').on 'change, change.select2', (e) ->
    toggle_fund_wallet()
    if $(this).val()
      $('#fund_operation_payment_resource_type_input').show()
      switch_payment_type($('input[name="fund_operation[payment_resource_type]"]:checked').get 0)
      $('#fund_operation_instrument_input').hide()
    else
      $('#fund_operation_instrument_input').show()
      $('#fund_operation_currency_input').show()
      $('#fund_operation_payment_resource_type_input').hide()
      hide_wallets_input()
    return

  $('#fund_operation_instrument_id').on 'change, change.select2', (e) ->
    toggle_fund_wallet()
    if $(this).val()
      $('#fund_operation_investor_input').hide()
    else
      $('#fund_operation_investor_input').show()
    return

  $('input[name="fund_operation[payment_resource_type]"]').on 'change', ->
    switch_payment_type(this)
    return

  $('#fund_operation_operation_type').on 'change', ->
    toggle_fund_wallet()
    return

  $('#fund_operation_investor_id').trigger 'change'
  $('#fund_operation_instrument_id').trigger 'change'
