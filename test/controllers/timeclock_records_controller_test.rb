require 'test_helper'

class TimeclockRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @timeclock_record = timeclock_records(:one)
  end

  test "should get index" do
    get timeclock_records_url
    assert_response :success
  end

  test "should get new" do
    get new_timeclock_record_url
    assert_response :success
  end

  test "should create timeclock_record" do
    assert_difference('TimeclockRecord.count') do
      post timeclock_records_url, params: { timeclock_record: {  } }
    end

    assert_redirected_to timeclock_record_url(TimeclockRecord.last)
  end

  test "should show timeclock_record" do
    get timeclock_record_url(@timeclock_record)
    assert_response :success
  end

  test "should get edit" do
    get edit_timeclock_record_url(@timeclock_record)
    assert_response :success
  end

  test "should update timeclock_record" do
    patch timeclock_record_url(@timeclock_record), params: { timeclock_record: {  } }
    assert_redirected_to timeclock_record_url(@timeclock_record)
  end

  test "should destroy timeclock_record" do
    assert_difference('TimeclockRecord.count', -1) do
      delete timeclock_record_url(@timeclock_record)
    end

    assert_redirected_to timeclock_records_url
  end
end
