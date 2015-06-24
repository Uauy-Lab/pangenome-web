class MutantLinesController < ApplicationController
  before_action :set_mutant_line, only: [:show, :edit, :update, :destroy]

  # GET /mutant_lines
  # GET /mutant_lines.json
  def index
    @mutant_lines = MutantLine.all
  end

  # GET /mutant_lines/1
  # GET /mutant_lines/1.json
  def show
  end

  # GET /mutant_lines/new
  def new
    @mutant_line = MutantLine.new
  end

  # GET /mutant_lines/1/edit
  def edit
  end

  # POST /mutant_lines
  # POST /mutant_lines.json
  def create
    @mutant_line = MutantLine.new(mutant_line_params)

    respond_to do |format|
      if @mutant_line.save
        format.html { redirect_to @mutant_line, notice: 'Mutant line was successfully created.' }
        format.json { render :show, status: :created, location: @mutant_line }
      else
        format.html { render :new }
        format.json { render json: @mutant_line.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mutant_lines/1
  # PATCH/PUT /mutant_lines/1.json
  def update
    respond_to do |format|
      if @mutant_line.update(mutant_line_params)
        format.html { redirect_to @mutant_line, notice: 'Mutant line was successfully updated.' }
        format.json { render :show, status: :ok, location: @mutant_line }
      else
        format.html { render :edit }
        format.json { render json: @mutant_line.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mutant_lines/1
  # DELETE /mutant_lines/1.json
  def destroy
    @mutant_line.destroy
    respond_to do |format|
      format.html { redirect_to mutant_lines_url, notice: 'Mutant line was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mutant_line
      @mutant_line = MutantLine.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mutant_line_params
      params.require(:mutant_line).permit(:name, :description)
    end
end
