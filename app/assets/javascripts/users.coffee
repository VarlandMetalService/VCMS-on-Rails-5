# Required in order to run Holder.js without full page refresh
$(document).bind 'turbolinks:load', ->
  Holder.run()