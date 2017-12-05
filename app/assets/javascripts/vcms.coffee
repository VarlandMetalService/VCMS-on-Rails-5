# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', (event) ->
  if window.location.pathname == '/ipad' || window.location.pathname == '/ipad/enter_pin'
    $('.flash-message').fadeOut(3000)

  # Show/Hide Filter Form
  $('.display-filter').on 'click', ->
    if $(this).html() == 'Show Filter'
      $(this).html('Hide Filter')
    else
      $(this).html('Show Filter')
    $('.filter-form').toggle();