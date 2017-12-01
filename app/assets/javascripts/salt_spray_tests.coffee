# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# color Salt Spray Tests table based on process
colorTable = () ->
  $('#salt_spray_test_results').find('div.process').each ->
    $(this).closest('.row').find('div').addClass 'row-color-' + $(this).text()
    return

$(document).on 'turbolinks:load', (event) ->
  colorTable()
  $(document).ajaxSuccess ->
    colorTable()

  # Show/Hide Filter Form
  $('.display-filter').on 'click', ->
    if $(this).html() == 'Show Filter'
      $(this).html('Hide Filter')
    else
      $(this).html('Show Filter')
    $('.filter-form').toggle();

  # Clear Marked White Field
  $('.clear-white').on 'click', ->
    $('.marked-white-date').val('')
    $('.marked-white-reporter').val('')

  # Clear Marked Red Field
  $('.clear-red').on 'click', ->
    $('.marked-red-date').val('')
    $('.marked-red-reporter').val('')

  # Clear Comment Field
  $('.clear-comment').on 'click', ->
    $(this).closest('.row').find('textarea').val('')

  # Manual entry modal functionality
  $(document).on 'click', '.manual-entry-yes', ->
    $('.manual-entry-inputs input').prop({
      required: true,
      disabled: false
    });
    $('.manual-entry-inputs').removeClass('display-none');
    $('#manual_entry_modal').modal('hide');

  # "Test Complete?" modal functionality
  $('.open-submit-modal').on 'click', (event) ->
    $('.test-complete-' + $(event.target).data('spot')).addClass('trigger-test-complete');

  $('#test-complete-modal').on 'hidden.bs.modal', (event) ->
    $('.trigger-test-complete').removeClass('trigger-test-complete');

  $('.test-complete-confirm').on 'click', (event) ->
    if $(event.target).attr('name') == 'yes'
        $('.form-submit-date-off').val(Date)
        $('.form-submit-archived').val(true)
    $('.trigger-test-complete').trigger('click');
    $('.trigger-test-complete').removeClass('trigger-test-complete');

  # Give file input field label the look and feel of the file input field
  # (_new_attachment_fields.html.erb)
  $('body').on 'change', '.inputfile', (e) ->
    $input = $(this)
    $label = $input.next('label')
    labelVal = $label.html()
    fileName = ''
    if @files and @files.length > 1
      fileName = (@getAttribute('data-multiple-caption') or '').replace('{count}', @files.length)
    else if e.target.value
      fileName = e.target.value.split('\\').pop()
    if fileName
      if fileName.length > 25 then fileName = fileName.substring(0, 25) + '...'
      $label.html fileName
    else
      $label.html labelVal
    return
  # Firefox bug fix
  $('body').on('focus', '.inputfile', ->
    $(this).addClass 'has-focus'
    return
  ).on 'blur', ->
    $(this).removeClass 'has-focus'
    return
  return



