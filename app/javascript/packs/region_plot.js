class RegionPlot{
	constructor(svg_g, x,y, status){
		this._y = y;
		this._x = x;
		this._previous_x = d3.scaleLinear();
		this.status = status;
		this.svg_plot_elements = svg_g;

		let length = 32;
		this.g_id =  Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
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

	get plot_height(){
		var r = this.y.range();
		return r[1] - r[0];
	}

	get plot_width(){
		var r = this.x.range();
		return r[1] - r[0];
	}

}

window.RegionPlot = RegionPlot;