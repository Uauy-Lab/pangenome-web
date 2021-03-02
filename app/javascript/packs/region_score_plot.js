class RegionScorePlot extends RegionPlot{
	constructor(svg_g, x, y, color, margin, status){
		super(svg_g, x, y, status);
		this._margin = margin;
		this._values = [];
		this.color = color;
		this._region_scores = null;
		this.g = svg_g.append("g");
		this.g.classed("regions-score-plot", true);
		console.log("Returnng from constructor")
	}

	get values(){
		// return this._values;
		console.log("Values...")
		console.log(this);
		console.log(this.status);
		var vals = this._region_scores.values(0,0,this.status.display_score)
		return vals;
	}	

	// set values(newValues){
	// 	var self = this;

	// 	//this._values = newValues;
	// 	//super.update(500);
	// }

	set region_scores(rs){
		this._region_scores = rs;
	}

	set offset(offset){
		this._offset = offset;
	}

	set width(w){
		this._width = w;
	}

	set id(id){
		this._id = id;
		this.g.classed(id, true);
	}

	remove(){
		this.selectAll(this._id).remove();
	}

	renderPlot(){
		console.log("Rendering region score plot");
		this.points_g = this.g.append("g");
		this.points_g.classed("value-points", true);
		this.points_g.attr("transform", "translate(" + this._margin.left + ",0)")
	}


	moveDots(update, duration){
		var self = this;
		return update
		// .transition()
		// .duration(duration)
		.attr ("cx",   d => self.x(d.start)        )
      	.attr ("cy",   d => self.y(d.value)        );
      	//.style("fill", d => self.color(d.assembly) );
	}

	update(duration){
		var self = this;
		//this.points_g.selectAll(".value_point").remove();
		this.points_g.selectAll(".value_point")
		.data(this.values, d => d.id)
		.join(
			enter => 
				enter.append("circle")	
      			.attr("r", 1.5)
      			.attr("class","value_point")
      			.call(enter => self.moveDots(enter, duration))
      		,
      		update => self.moveDots(update, duration),
      		exit   => self.moveDots(exit, duration)
		);
	}

}

window.RegionScorePlot = RegionScorePlot;