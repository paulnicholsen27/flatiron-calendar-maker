require 'test_helper'

class MainControllerTest < ActionDispatch::IntegrationTest
  test "should get homepage" do
    get main_homepage_url
    assert_response :success
  end

end
