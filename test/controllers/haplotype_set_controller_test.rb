require 'test_helper'

class HaplotypeSetControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get haplotype_set_index_url
    assert_response :success
  end

  test "should get show" do
    get haplotype_set_show_url
    assert_response :success
  end

end
