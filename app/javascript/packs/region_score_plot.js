class RegionScorePlot extends RegionPlot{
	#highligted;
	#mapped_coords
	constructor(svg_g, x, y, color, margin, status){
		super(svg_g, x, y, status);
		this._margin = margin;
		this._values = [];
		this._region_scores = null;
		this.g = svg_g.append("g");
		this.g.attr("id", this.g_id);
		this.g.classed("regions-score-plot", true);
		this.axis_g = this.g.append("g");

		this.scores_axis = new RegionScoreAxis(this.axis_g, this.status.y_scores, this, this.status);
		this.scores_axis.translate(this._margin.left, 0);
		this.scores_axis.align_labels("end");
		this.clip_id = "clip-" + this.g_id;
		this.defs = this.g.append("defs");
		this.clip_path = this.defs.append("svg:clipPath").attr("id", this.clip_id);
	    this.clip_rect = this.clip_path.append("svg:rect")
	      .attr("x", 0)
	      .attr("y", 0);		
	}

	get values(){
		var domain = this.status.x.domain();
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
		this.points_g = this.g.append("g");
		this.points_g.classed("value-points", true)
		.attr("transform", "translate(" + this._margin.left + ",0)")
		.attr("clip-path", "url(#" + this.clip_id + ")");
		this.title = this.g.append("text")
        .attr("text-anchor", "middle")  
        .style("font-size", "16px") 
        .style("text-decoration", "underline")
        .text("Title");
	}

	get color(){
		return this.status.color;
	}

	radious(region){
		var ret = 1.5;
		return ret;
	}	

	opacity(region){
		var ret = 0.75;
		if(this.#highligted.length > 0){
			var highligted = this.#highligted.reduce( 
				(ret, r) =>  ret || r.overlap(region) ,
				false)
			ret = highligted ? 1 : 0.2;
		}

		return ret;
	}

	region_color(region){
		var ret = "black";
		//this.color(d.assembly)
		
		return ret;
	}

	moveDots(update, duration){
		return update
		.transition()
		.duration(duration)
		.attr("r",        d => this.radious(d)      )
		.attr ("cx",      d => this.x(d.start)      )
      	.attr ("cy",      d => this.y(d.value)      )
     	.style("fill",    d => this.region_color(d) )
     	.style("opacity", d => this.opacity(d)      );
	}

	updateTitle(){
		var range = this.status.x.range();
		this.title.attr("x", this._margin.left + (range[1] / 2));
		this.title.attr("y", "20px");
		this.title.text(this._region_scores.title);
	}

	update(duration){
		var self = this;
		var vals = this.values;
		if(vals.length > 1500){
			duration = 0;
		}
		var width  = this.plot_width ;
		var height = this.plot_height ;

		this.#highligted = this.status.region_feature_set.overlaps(vals);
		this.#mapped_coords    = this.status.mapped_coords;

		console.log(this.#highligted);
		console.log(this.#mapped_coords);
		this.clip_rect
		.attr("width", width  )
	    .attr("height",height );
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