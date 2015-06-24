require 'test_helper'

class MutationConsequencesControllerTest < ActionController::TestCase
  setup do
    @mutation_consequence = mutation_consequences(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mutation_consequences)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mutation_consequence" do
    assert_difference('MutationConsequence.count') do
      post :create, mutation_consequence: { description: @mutation_consequence.description, name: @mutation_consequence.name }
    end

    assert_redirected_to mutation_consequence_path(assigns(:mutation_consequence))
  end

  test "should show mutation_consequence" do
    get :show, id: @mutation_consequence
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mutation_consequence
    assert_response :success
  end

  test "should update mutation_consequence" do
    patch :update, id: @mutation_consequence, mutation_consequence: { description: @mutation_consequence.description, name: @mutation_consequence.name }
    assert_redirected_to mutation_consequence_path(assigns(:mutation_consequence))
  end

  test "should destroy mutation_consequence" do
    assert_difference('MutationConsequence.count', -1) do
      delete :destroy, id: @mutation_consequence
    end

    assert_redirected_to mutation_consequences_path
  end
end
