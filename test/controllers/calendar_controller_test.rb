require 'test_helper'

class CalendarsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get calendar_new_url
    assert_response :success
  end

end
