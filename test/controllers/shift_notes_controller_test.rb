require 'test_helper'

class ShiftNotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @shift_note = shift_notes(:one)
  end

  test "should get index" do
    get shift_notes_url
    assert_response :success
  end

  test "should get new" do
    get new_shift_note_url
    assert_response :success
  end

  test "should create shift_note" do
    assert_difference('ShiftNote.count') do
      post shift_notes_url, params: { shift_note: {  } }
    end

    assert_redirected_to shift_note_url(ShiftNote.last)
  end

  test "should show shift_note" do
    get shift_note_url(@shift_note)
    assert_response :success
  end

  test "should get edit" do
    get edit_shift_note_url(@shift_note)
    assert_response :success
  end

  test "should update shift_note" do
    patch shift_note_url(@shift_note), params: { shift_note: {  } }
    assert_redirected_to shift_note_url(@shift_note)
  end

  test "should destroy shift_note" do
    assert_difference('ShiftNote.count', -1) do
      delete shift_note_url(@shift_note)
    end

    assert_redirected_to shift_notes_url
  end
end
