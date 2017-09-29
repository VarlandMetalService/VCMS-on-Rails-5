require 'test_helper'

class OptoMessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @opto_message = opto_messages(:one)
  end

  test "should get index" do
    get opto_messages_url
    assert_response :success
  end

  test "should get new" do
    get new_opto_message_url
    assert_response :success
  end

  test "should create opto_message" do
    assert_difference('OptoMessage.count') do
      post opto_messages_url, params: { opto_message: {  } }
    end

    assert_redirected_to opto_message_url(OptoMessage.last)
  end

  test "should show opto_message" do
    get opto_message_url(@opto_message)
    assert_response :success
  end

  test "should get edit" do
    get edit_opto_message_url(@opto_message)
    assert_response :success
  end

  test "should update opto_message" do
    patch opto_message_url(@opto_message), params: { opto_message: {  } }
    assert_redirected_to opto_message_url(@opto_message)
  end

  test "should destroy opto_message" do
    assert_difference('OptoMessage.count', -1) do
      delete opto_message_url(@opto_message)
    end

    assert_redirected_to opto_messages_url
  end
end
