import  * as d3 from 'd3'
class RegionScorePlotContainer extends PlotContainer{
	constructor(svg_g, width, height, x, y, current_status, margin, rsc){
		super(svg_g, width, height, 0, 0, current_status);
		this._margin=margin;

		//this.g.append("text","hi");
		this.plots = new Map();
		// console.log("RegionScorePlotContainer");
		// console.log(this);
	}


	get domain(){
		var vals = [];
		var self = this;
		this.plots.forEach( (v,k) =>
					vals.push(
						v._region_scores.range(
							this._current_status.display_score)))
		vals = vals.flat()
		return [d3.max(vals), d3.min(vals)];
	}

	get height_per_plot(){
		return  this._height / this.plots.size ;
	}
	
	addPlot(id, region_scores){
		id = id.replace(/ /g,"_");
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
		id = id.replace(/ /g,"_");
		var refresh = this.plots.has(id);
		this.plots.delete(id);
		var tmp = this.g.selectAll("."+ id ).remove();
		if(refresh){
			this.refresh_range(0);
		}
	}

	renderPlot(){
		//this._current_status.y_scores_full.rangeRound([0,this._height]);
		this.axis_g = this.g.append("g");
		this.axis_g.attr("transform", "translate("+ this._margin.left/2 +",0)");

		this.all_scores_axis = new RegionScoreAxis(
			this.axis_g, 
			this._current_status.y_scores_full, 
			this._current_status.target, 
			this._current_status,
			"y");
		this.all_scores_axis.align_labels("end");
		this.all_scores_axis.enable_drag();
	}

	update(){
		this.refresh_range(0);
	}

	refreshAxis(){
		if(this.all_scores_axis){
			this._current_status.y_scores_full.rangeRound([0,this._height]);
			this._current_status.y_scores_full.domain(this.domain);
			this.all_scores_axis.bar_properties.resize_range = true;
			this.all_scores_axis.refresh_range(500);
		}
	}

	update_plot_positons(){
		var i = 0
		var offset_size = this.height_per_plot;
		var self = this;

		this.height = this._current_status.plot_height - this._margin.rendered_height
		// console.log("update_plot_positons");
		this.refreshAxis();
		this._current_status.displayed_assemblies.forEach((v,k)=>{
			if(v){
				this._current_status.display_samples.forEach(s => {
					var id = s + "-" + k;
					id = id.replace(/ /g,"_");
					var tmp = self.plots.get(id);
					if(tmp){
						tmp.offset = i * offset_size;
						i++;
					}
				})
			}
		})
	}

	// get plot_height(){
	// 	//var offset = this._margin.rendered_height - this._margin.bottom;
	// 	return this.height_per_plot - offset;
	// }

	refresh_range(duration){
		var left = this._margin.left;
		this.update_plot_positons();
		// console.log("refresh_range");
		// console.log(this._margin);
		var offset = this._margin.rendered_height - this._margin.bottom;
		this._current_status.y_scores.rangeRound([0,this.height_per_plot]);
		this.g.attr("transition", duration);
		this.g.attr("transform", "translate(0, "+ offset +")")
		this.plots.forEach((v,k) =>{ 
			v.update(duration)
		});
	}

	


}

window.RegionScorePlotContainer = RegionScorePlotContainer;