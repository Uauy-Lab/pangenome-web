class RegionScorePlot extends RegionPlot{
	constructor(svg_g, x, y, color, status){
		super(svg_g, x, y, color, status);
		this._values = [];
	}

	get values(){
		return this._values;
	}	

	set values(newValues){
		var self = this;
		this._values = newValues;
		super.update(500);
	}

	set offset(offset){
		this._offset = offset;
	}

	set width(w){
		this._width = w;
	}

	renderPlot(){
		this.points_g = this.g.append("g");
		this.points_g.classed("value-points", true);
	}

	moveDots(update, duration){
		var self = this;
		return update
		.transition()
		.duration(duration)
		.attr ("cx",   d => self.x(d.start)        )
      	.attr ("cy",   d => self.y(d.value)        )
      	.style("fill", d => self.color(d.assembly) );
	}

	update(duration){
		var rendered_scores = this._values;
		var self = this;
		this.points_g.selectAll(".value-point")
		.data(this._values)
		.join(
			enter => 
				enter.append("circle")	
      			.attr("r", 1.5)
      			.call(enter => self.moveDots(enter, duration))
      		,
      		update => self.moveDots(update, duration),
      		exit   => self.moveDots(exit, duration)
		);
	}

}