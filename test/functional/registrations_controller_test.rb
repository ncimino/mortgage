require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  test "should get calculator" do
    get :calculator
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

end
