# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', (event) ->
  $('.number-button').on 'touchend', ->
    employeePin = $('#employee-number-field').val()
    if employeePin.length < 3
      employeePin += $(this).text()
      $('#employee-number-field').val(employeePin)
    return

  $('.bksp-button').on 'touchend', ->
    employeePin = $('#employee-number-field').val()
    if employeePin.length > 0
      employeePin = employeePin.substring(0, employeePin.length - 1)
      $('#employee-number-field').val(employeePin)
    return

