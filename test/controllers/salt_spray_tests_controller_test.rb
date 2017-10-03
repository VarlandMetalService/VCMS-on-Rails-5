require 'test_helper'

class SaltSprayTestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @salt_spray_test = salt_spray_tests(:one)
  end

  test "should get index" do
    get salt_spray_tests_url
    assert_response :success
  end

  test "should get new" do
    get new_salt_spray_test_url
    assert_response :success
  end

  test "should create salt_spray_test" do
    assert_difference('SaltSprayTest.count') do
      post salt_spray_tests_url, params: { salt_spray_test: {  } }
    end

    assert_redirected_to salt_spray_test_url(SaltSprayTest.last)
  end

  test "should show salt_spray_test" do
    get salt_spray_test_url(@salt_spray_test)
    assert_response :success
  end

  test "should get edit" do
    get edit_salt_spray_test_url(@salt_spray_test)
    assert_response :success
  end

  test "should update salt_spray_test" do
    patch salt_spray_test_url(@salt_spray_test), params: { salt_spray_test: {  } }
    assert_redirected_to salt_spray_test_url(@salt_spray_test)
  end

  test "should destroy salt_spray_test" do
    assert_difference('SaltSprayTest.count', -1) do
      delete salt_spray_test_url(@salt_spray_test)
    end

    assert_redirected_to salt_spray_tests_url
  end
end
