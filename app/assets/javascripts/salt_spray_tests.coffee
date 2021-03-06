enableOtherField = (field) ->
  write_in = $(field).next('input')
  if $(field).find(":selected").text() == 'Other'
    write_in.prop('disabled', false)
    write_in.removeClass('d-none')
  else
    write_in.val("")
    write_in.prop('disabled', true)
    write_in.addClass('d-none')

$(document).on 'turbolinks:load', (event) ->

  if $(document).width() >= 768
    $('.rust-spot-info.ipad').removeClass('d-none')
    $('.rust-spot-info.iphone').addClass('d-none')

  $('#salt_spray_processes').on 'cocoon:after-insert', ->
    $('.trigger-other').on 'change', ->
      enableOtherField(this)

  # Undo Mark functionality
  $('.undo-mark').on 'click', ->
    $(this).parent().find('.undo-target').prop('disabled', false)

  # Undo Archive functionality
  $('.undo-archive').on 'click', ->
    $(this).parent().find('.undo-archive-target').prop('disabled', false)

  # Convert To Sample functionality
  $('.convert-sample').on 'click', ->
    $(this).parent().find('.convert-sample-target').prop('value', true)

  # Write-in field functionality for process steps
  $('.trigger-other').on 'change', ->
    enableOtherField(this)

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

  # Toggle 'Flag For Editing'
  $('.flag-test').on 'click', ->
    if $(this).html() == 'Add Flag'
      $(this).html("Remove Flag")
      $('.flag-icon').removeClass('d-none')
    else
      $(this).html("Add Flag")
      $('.flag-icon').addClass('d-none')
    $('.toggle-flagged-by').prop 'disabled', (i, v) ->
      return !v

  # "Test Complete?" modal functionality
  $('.open-submit-modal').on 'click', (event) ->
    $(event.target).closest('.row').find('.test-complete-' + $(event.target).data('spot')).addClass('trigger-test-complete');

  $('#test-complete-modal').on 'hidden.bs.modal', (event) ->
    $('.trigger-test-complete').removeClass('trigger-test-complete');

  $('.test-complete-confirm').on 'click', (event) ->
    if $(event.target).attr('name') == 'yes'
        $('.form-submit-date-off').val(Date)
        $('.form-submit-off-by').prop('disabled', false)
        $('.form-submit-archived').val(true)
    $('.trigger-test-complete').trigger('click');
    $('.trigger-test-complete').removeClass('trigger-test-complete');

  # Give file input field label the look and feel of the file input field
    # Styling hack for file input fields
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



