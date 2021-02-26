class RegionScorePlotContainer extends PlotContainer{
	constructor(svg_g, width, height, x, y, current_status, margin){
		super(svg_g, width, height, 0, 0, current_status);
		this._margin=margin
		//this.g.append("text","hi")
	}

	addPlot(id, region_scores){

	}

	removePlot(id){

	}
	renderPlot(){}

	


}

window.RegionScorePlotContainer = RegionScorePlotContainer;