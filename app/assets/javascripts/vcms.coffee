# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

queryStringExists = () ->
  url = window.location.href
  field = 'with_shop_order_number'
  if url.indexOf('?' + field + '=') != -1
    return true
  else if url.indexOf('&' + field + '=') != -1
    return true
  false

toggleFilterBtn = (obj) ->
  if $(obj).html() == 'Show Filter'
    $(obj).html('Hide Filter')
  else
    $(obj).html('Show Filter')
  $('.filter-form').toggle();


$(document).on 'turbolinks:load', (event) ->
  if window.location.pathname == '/ipad' || window.location.pathname == '/ipad/enter_pin'
    $('.flash-message').fadeOut(3000)

  if queryStringExists()
    toggleFilterBtn($('.display-filter'))

  # Show/Hide Filter Form
  $('.display-filter').on 'click', ->
    toggleFilterBtn(this)