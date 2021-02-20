class RegionScorePlot extends RegionPlot{
	constructor(svg_g, x, y, color, status){
		super(svg_g, x, y, color, status);
	}

	get values(){
		return this._regions;
	}	

	set values(newValues){
		var self = this;
		this.previous_x.range(this.x.range());
		this.previous_x.domain(this.x.domain());
		super.update_coords();
	}

	set offset(offset){
		this._offset = offset;
	}

	set width(widht){
		this._width = width;
	}


}