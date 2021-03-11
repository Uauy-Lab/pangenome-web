class RegionScorePlot extends RegionPlot{
	constructor(svg_g, x, y, color, margin, status){
		super(svg_g, x, y, status);
		this._margin = margin;
		this._values = [];
		this.color = color;
		this._region_scores = null;
		this.g = svg_g.append("g");
		this.g.classed("regions-score-plot", true);
		// console.log("Returnng from constructor")
		// this.g.attr("transition", 500);
		this.axis_g = this.g.append("g");

		this.scores_axis = new RegionScoreAxis(this.axis_g, this.status.y_scores, this, this.status);
		this.scores_axis.translate(this._margin.left, 0);
		this.scores_axis.align_labels("end");

		//this.scores_axis.axis_g.tickPadding(20)
		this.title = this.g.append("text")            
        //.attr("y", 0 - (this._margin.top / 2))
        .attr("text-anchor", "middle")  
        .style("font-size", "16px") 
        .style("text-decoration", "underline")
        //.classed("scorePlotTitle")  
        .text("Title");
	}

	get values(){
		// return this._values;
		// console.log("Values...")
		// console.log(this);
		// console.log(this.status);
		var domain = this.status.x.domain();
		// console.log(domain);
		var vals = this._region_scores.values(domain[0],domain[1],this.status.display_score)
		return vals;
	}	

	set region_scores(rs){
		this._region_scores = rs;
	}

	set offset(offset){
		this.g.attr("transform", "translate(0,"+ offset +")");
		this._offset = offset;
	}

	set width(w){
		console.log("Setting width: ${w} ");
		console.log(w); 
		
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
		// console.log("Rendering region score plot");
		this.points_g = this.g.append("g");
		this.points_g.classed("value-points", true)
		.attr("transform", "translate(" + this._margin.left + ",0)")
		.attr("clip-path", "url(#clip)")
	}


	moveDots(update, duration){
		var self = this;
		return update
		.transition()
		.duration(duration)
		.attr ("cx",   d => self.x(d.start)  )
      	.attr ("cy",   d => self.y(d.value)  );
      	//.style("fill", d => self.color(d.assembly) );
	}

	updateTitle(){
		var range = this.status.x.range();
		this.title.attr("x", (range[1] / 2));
		this.title.attr("y", "20px");
		
		this.title.text(this._region_scores.title);
		

	}

	update(duration){
		var self = this;
		//this.points_g.selectAll(".value_point").remove();
		var vals = this.values;
		if(vals.length > 1500){
			duration = 0;
		}

		this.updateTitle();

		this.scores_axis.refresh_range(duration);

		this.points_g.selectAll(".value_point")
		.data(vals, d => d.id)
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