require 'test_helper'

class DeletionsControllerTest < ActionController::TestCase
  test "should get query_for_lines" do
    get :query_for_lines
    assert_response :success
  end

end
