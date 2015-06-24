require 'test_helper'

class MutantLinesControllerTest < ActionController::TestCase
  setup do
    @mutant_line = mutant_lines(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mutant_lines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mutant_line" do
    assert_difference('MutantLine.count') do
      post :create, mutant_line: { description: @mutant_line.description, name: @mutant_line.name }
    end

    assert_redirected_to mutant_line_path(assigns(:mutant_line))
  end

  test "should show mutant_line" do
    get :show, id: @mutant_line
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mutant_line
    assert_response :success
  end

  test "should update mutant_line" do
    patch :update, id: @mutant_line, mutant_line: { description: @mutant_line.description, name: @mutant_line.name }
    assert_redirected_to mutant_line_path(assigns(:mutant_line))
  end

  test "should destroy mutant_line" do
    assert_difference('MutantLine.count', -1) do
      delete :destroy, id: @mutant_line
    end

    assert_redirected_to mutant_lines_path
  end
end
