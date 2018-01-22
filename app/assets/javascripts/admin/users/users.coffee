$(document).on 'ready page:load turbolinks:load', ->
  
  # Hides the Add button if a `.has-one` element already exists
  $('.has-one .has_many_container').each (_, container) ->
    if $(container).find('ol').length
      $(container).find('a.has_many_add').hide()
    return

  $('.has_many_container.kyc_document a.has_many_add').on 'click', ->
    setTimeout (->
      if $('.has_many_container.kyc_document fieldset').length > 0
        $('.has_many_container.kyc_document a.has_many_add').hide()
      return
    ), 150

  $('.has_many_container.kyc_document').on 'click', 'a.has_many_remove', ->
    setTimeout (->
      if $('.has_many_container.kyc_document fieldset').length == 0
        $('.has_many_container.kyc_document a.has_many_add').show()
      return
    ), 150

  $('#user_role_ids').on 'change', ->
    if $(this).find(":selected").text() == 'Investor'
      $('#wallets-input').show()
      $('#kyc-inputs').show()
    else
      $('#wallets-input').hide()
      $('#kyc-inputs').hide()
  
  $('#user_role_ids').trigger 'change'