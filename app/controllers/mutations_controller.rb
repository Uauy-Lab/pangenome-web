class MutationsController < ApplicationController
  before_action :set_mutation, only: [:show, :edit, :update, :destroy]

  # GET /mutations
  # GET /mutations.json
  def index
    @mutations = Mutation.all
  end

  # GET /mutations/1
  # GET /mutations/1.json
  def show
  end

  # GET /mutations/new
  def new
    @mutation = Mutation.new
  end

  # GET /mutations/1/edit
  def edit
  end

  # POST /mutations
  # POST /mutations.json
  def create
    @mutation = Mutation.new(mutation_params)

    respond_to do |format|
      if @mutation.save
        format.html { redirect_to @mutation, notice: 'Mutation was successfully created.' }
        format.json { render :show, status: :created, location: @mutation }
      else
        format.html { render :new }
        format.json { render json: @mutation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mutations/1
  # PATCH/PUT /mutations/1.json
  def update
    respond_to do |format|
      if @mutation.update(mutation_params)
        format.html { redirect_to @mutation, notice: 'Mutation was successfully updated.' }
        format.json { render :show, status: :ok, location: @mutation }
      else
        format.html { render :edit }
        format.json { render json: @mutation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mutations/1
  # DELETE /mutations/1.json
  def destroy
    @mutation.destroy
    respond_to do |format|
      format.html { redirect_to mutations_url, notice: 'Mutation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mutation
      @mutation = Mutation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mutation_params
      params.require(:mutation).permit(:scaffold_id, :chromosome_id, :library, :mutant_line_id, :position, :ref_base, :wt_base, :alt_base, :het_hom, :wt_cov, :mut_cov, :confidence, :gene_id, :mutation_consequence_id, :cdna_position, :cds_position, :amino_acids, :codons, :sift_score)
    end
end
