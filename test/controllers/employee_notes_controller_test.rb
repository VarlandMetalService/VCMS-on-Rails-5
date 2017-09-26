require 'test_helper'

class EmployeeNotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee_note = employee_notes(:one)
  end

  test "should get index" do
    get employee_notes_url
    assert_response :success
  end

  test "should get new" do
    get new_employee_note_url
    assert_response :success
  end

  test "should create employee_note" do
    assert_difference('EmployeeNote.count') do
      post employee_notes_url, params: { employee_note: {  } }
    end

    assert_redirected_to employee_note_url(EmployeeNote.last)
  end

  test "should show employee_note" do
    get employee_note_url(@employee_note)
    assert_response :success
  end

  test "should get edit" do
    get edit_employee_note_url(@employee_note)
    assert_response :success
  end

  test "should update employee_note" do
    patch employee_note_url(@employee_note), params: { employee_note: {  } }
    assert_redirected_to employee_note_url(@employee_note)
  end

  test "should destroy employee_note" do
    assert_difference('EmployeeNote.count', -1) do
      delete employee_note_url(@employee_note)
    end

    assert_redirected_to employee_notes_url
  end
end
