class MutationConsequencesController < ApplicationController
  before_action :set_mutation_consequence, only: [:show, :edit, :update, :destroy]

  # GET /mutation_consequences
  # GET /mutation_consequences.json
  def index
    @mutation_consequences = MutationConsequence.all
  end

  # GET /mutation_consequences/1
  # GET /mutation_consequences/1.json
  def show
  end

  # GET /mutation_consequences/new
  def new
    @mutation_consequence = MutationConsequence.new
  end

  # GET /mutation_consequences/1/edit
  def edit
  end

  # POST /mutation_consequences
  # POST /mutation_consequences.json
  def create
    @mutation_consequence = MutationConsequence.new(mutation_consequence_params)

    respond_to do |format|
      if @mutation_consequence.save
        format.html { redirect_to @mutation_consequence, notice: 'Mutation consequence was successfully created.' }
        format.json { render :show, status: :created, location: @mutation_consequence }
      else
        format.html { render :new }
        format.json { render json: @mutation_consequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mutation_consequences/1
  # PATCH/PUT /mutation_consequences/1.json
  def update
    respond_to do |format|
      if @mutation_consequence.update(mutation_consequence_params)
        format.html { redirect_to @mutation_consequence, notice: 'Mutation consequence was successfully updated.' }
        format.json { render :show, status: :ok, location: @mutation_consequence }
      else
        format.html { render :edit }
        format.json { render json: @mutation_consequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mutation_consequences/1
  # DELETE /mutation_consequences/1.json
  def destroy
    @mutation_consequence.destroy
    respond_to do |format|
      format.html { redirect_to mutation_consequences_url, notice: 'Mutation consequence was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mutation_consequence
      @mutation_consequence = MutationConsequence.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mutation_consequence_params
      params.require(:mutation_consequence).permit(:name, :description)
    end
end
