import  * as d3 from 'd3'
class RegionScorePlotContainer extends PlotContainer{
	constructor(svg_g, width, height, x, y, current_status, margin, rsc){
		super(svg_g, width, height, 0, 0, current_status);
		this._margin=margin;

		//this.g.append("text","hi");
		this.plots = new Map();
		console.log("RegionScorePlotContainer");
		console.log(this);
	}


	get domain(){
		var vals = [];
		var self = this;
		this.plots.forEach( (v,k) =>
					vals.push(
						v._region_scores.range(
							this._current_status.display_score)))
		vals = vals.flat()
		return [d3.min(vals), d3.max(vals)];
	}

	get height_per_plot(){
		return  this._height / this.plots.size ;
	}
	
	addPlot(id, region_scores){
		if(this.plots.has(id)){
			return;
		}
		var plot = new RegionScorePlot(
			this.g, 
			this._current_status.x, 
			this._current_status.y_scores, 
			this._current_status.color_axis,
			this._margin,
			this._current_status);
		plot.region_scores = region_scores;
		plot.id = id;
		plot.renderPlot();
		this.plots.set(id, plot);
		this._current_status.y_scores.domain(this.domain);
		this._current_status.y_scores.rangeRound([0,this.height_per_plot]);
		this.refresh_range(500);
	}

	removePlot(id){
		this.plots.remove(set)
	}

	renderPlot(){

	}

	update(){
		this.refresh_range(500);
	}

	refresh_range(duration){
		var left = this._margin.left
		// console.log("refresh_range");
		// console.log(this._margin);
		var offset = this._margin.rendered_height - this._margin.bottom;

		this._current_status.y_scores.rangeRound([0,this.height_per_plot - offset]);
		this.g.attr("transform", "translate(0, "+ offset +")")
		this.plots.forEach((v,k) =>{ 
			v.update(duration)

		});


	}

	


}

window.RegionScorePlotContainer = RegionScorePlotContainer;