# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

timedRedirect = () ->
  window.location = '/ipad'

$(document).on 'turbolinks:load', ->
  setTimeout timedRedirect, 3000 if $('.timed-redirect').length

