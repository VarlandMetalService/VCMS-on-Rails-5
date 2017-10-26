# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', (event) ->
  if window.location.href == 'http://localhost:3000/ipad'
    $('.flash-message').fadeOut(3000)