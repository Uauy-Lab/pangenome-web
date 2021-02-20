class RegionPlot{
	constructor(svg_g, x,y, status){
		this._y = y;
		this._x = x;
		this._previous_x = d3.scaleLinear();
		this.status = status;
		this.svg_plot_elements = svg_g;
	}

	update_coords(){
		this._previous_x.range(this._x.range());
		this._previous_x.domain(this._x.domain());
	}

	get x(){
		return this._x;
	}
	get y(){
		return this._y;
	}

	get previous_x(){
		return this._previous_x;
	}

}

window.RegionPlot = RegionPlot;