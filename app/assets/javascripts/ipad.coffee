# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', (event) ->

  # Update IPad clock
  setInterval (->
    now = moment().format('ddd - MM/D - H:mm:ss a')
    $('.live-clock').html(now)
    return
  ), 1000

  $('.number-button').on 'touchend', ->
    employeePin = $(this).closest('form').find('.keypad-input').val()
    employeePinField = $(this).closest('form').find('.keypad-input')
    fieldLength = employeePinField.attr('maxlength')
    if employeePin.length < fieldLength
      employeePin += $(this).text()
      employeePinField.val(employeePin)
    return

  $('.bksp-button').on 'touchend', ->
    employeePin = $(this).closest('form').find('.keypad-input').val()
    employeePinField = $(this).closest('form').find('.keypad-input')
    if employeePin.length > 0
      employeePin = employeePin.substring(0, employeePin.length - 1)
      employeePinField.val(employeePin)
    return

  $('.enter-button').on 'touchend', ->
    $(this).closest('form').submit()

  $('#employee-number-dropdown').on 'change', ->
    employeePin = $(this).val().substring(0, 3)
    $('#employee-number-field').val(employeePin)
    $(this).closest('form').submit()


