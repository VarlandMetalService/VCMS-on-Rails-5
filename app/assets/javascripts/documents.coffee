# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  # $('.google-drive-url').change ->
    # Extract file id from text field
    # url = $(this).val()
    # if url.indexOf('https://docs.google.com/document/d/') >= 0
    #   doc_id = url.split("document/d/")
    #   if doc_id[1].indexOf("/") >= 0
    #     result = doc_id[1].split("/")[0]
    #     $('.google-doc-name').val(doc_name)
    #   else
    # return