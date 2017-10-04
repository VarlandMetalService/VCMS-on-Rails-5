# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

colorTable = () ->
  $('#salt_spray_test_results').find('td.process').each ->
    $(this).closest('tr').find('td').addClass 'row-color-' + $(this).text()
    return

$(document).on 'turbolinks:load', (event) ->
  colorTable()
  $('#salt-spray-table tr').on 'click', '.test-checkbox', (event) ->
    $.ajax
      cache: false
      type: 'PUT'
      url: 'salt_spray_tests/' + $(event.target).val()
      data: salt_spray_test: {checked: $(event.target).is(':checked')}
      dataType: 'script'
      success: setTimeout (->
          colorTable()
          return
        ), 1000
    return

  $(document).on 'click', '.manual-entry-yes', ->
    $('.manual-entry-inputs input').prop({
      required: true,
      disabled: false
    });
    $('.manual-entry-inputs').removeClass('display-none');
    $('#manual_entry_modal').modal('hide');

  $('.open-submit-modal').on 'click', (event) ->
    $('.test-complete-' + $(event.target).data('spot')).addClass('trigger-test-complete');

  $('.test-complete-confirm').on 'click', (event) ->
    if $(event.target).attr('name') == 'yes'
        $('.form-submit-date-off').val(Date)
        $('.form-submit-archived').val(true)
    $('.trigger-test-complete').trigger('click');
    $('.trigger-test-complete').removeClass('trigger-test-complete');

  $(document).ajaxSuccess ->
    colorTable()