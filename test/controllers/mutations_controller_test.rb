require 'test_helper'

class MutationsControllerTest < ActionController::TestCase
  setup do
    @mutation = mutations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mutations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mutation" do
    assert_difference('Mutation.count') do
      post :create, mutation: { alt_base: @mutation.alt_base, amino_acids: @mutation.amino_acids, cdna_position: @mutation.cdna_position, cds_position: @mutation.cds_position, chromosome_id: @mutation.chromosome_id, codons: @mutation.codons, confidence: @mutation.confidence, gene_id: @mutation.gene_id, het_hom: @mutation.het_hom, library: @mutation.library, mut_cov: @mutation.mut_cov, mutant_line_id: @mutation.mutant_line_id, mutation_consequence_id: @mutation.mutation_consequence_id, position: @mutation.position, ref_base: @mutation.ref_base, scaffold_id: @mutation.scaffold_id, sift_score: @mutation.sift_score, wt_base: @mutation.wt_base, wt_cov: @mutation.wt_cov }
    end

    assert_redirected_to mutation_path(assigns(:mutation))
  end

  test "should show mutation" do
    get :show, id: @mutation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mutation
    assert_response :success
  end

  test "should update mutation" do
    patch :update, id: @mutation, mutation: { alt_base: @mutation.alt_base, amino_acids: @mutation.amino_acids, cdna_position: @mutation.cdna_position, cds_position: @mutation.cds_position, chromosome_id: @mutation.chromosome_id, codons: @mutation.codons, confidence: @mutation.confidence, gene_id: @mutation.gene_id, het_hom: @mutation.het_hom, library: @mutation.library, mut_cov: @mutation.mut_cov, mutant_line_id: @mutation.mutant_line_id, mutation_consequence_id: @mutation.mutation_consequence_id, position: @mutation.position, ref_base: @mutation.ref_base, scaffold_id: @mutation.scaffold_id, sift_score: @mutation.sift_score, wt_base: @mutation.wt_base, wt_cov: @mutation.wt_cov }
    assert_redirected_to mutation_path(assigns(:mutation))
  end

  test "should destroy mutation" do
    assert_difference('Mutation.count', -1) do
      delete :destroy, id: @mutation
    end

    assert_redirected_to mutations_path
  end
end
