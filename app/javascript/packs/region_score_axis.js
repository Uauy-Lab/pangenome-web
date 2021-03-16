class RegionScoreAxis extends Axis{
	constructor(svg_g, scale, target, status ){
		super(svg_g, scale, d3.axisLeft, status);
		
		this.axis_g.attr("class",  "y axis");
		this.target = target;
	}

	translateRect(){

	}
	
	refresh_brush(){
		console.log("Refreshing brush");
		console.log(this._width());
		var full_domain = this.scale.domain();
		this.brush.extent( [ [-10, 0], [10, full_domain[1]] ]);
	}

	refresh_range(duration){		
		var scale = this.scale;
		var max = scale.range()[1];
		var ticks = Math.round( max / 25);
		ticks = ticks < 2 ? 2 : ticks;
		this.axis_g.transition().duration(duration).call(
			d3.axisLeft(this.scale).ticks(ticks)
		);

		if(this.dragrect){
			this.refresh_drag(duration);
		}
	}

	refresh_drag(duration){
		//var d = this.bar_properties;
		if(this.bar_properties.resize_range){
			let range = this.scale.range();
			this.bar_properties.height = range[1];
			this.bar_properties.resize_range = false;
		}

		if(duration > 0){
			console.log("updating")
			let domain = this.status.y_scores_domain;
			console.log(domain)
			let y = this.scale(domain[0]);
			let h = this.scale(domain[1]) - this.scale(domain[0]);
			console.log(`${y} : ${h}`)
  			//this.bar_properties.y     = this.scale(domain[0])
  			this.bar_properties.height = h ;
  			
  		}
		
		var bp = this.bar_properties;
		this.dragrect.data([this.bar_properties])
  		.transition()
	   	.duration(duration)
        .attr("x", function(d) { return d.x; })
      	.attr("y", function(d) { return d.y; })
      	.attr("height", `${bp.height}` )
      	.attr("width",  function(d){return d.width});

      	this.dragbartop
      	.transition()
	   	.duration(duration)
	   	.attr("y", `${bp.y - (bp.dragbarw/2)}`)

      	this.dragbarbottom
      	.transition()
	   	.duration(duration)
	   	.attr("y",  `${bp.y +  bp.height - (bp.dragbarw/2)}`)
	}

	enable_drag(){
		var self = this;
		var range = this.scale.range();
		this.bar_properties = {x: -8, y: 0, width: 16, height: 0 , dragbarw:2, resize_range:true};
		var drag = d3.drag()
			.on("drag", () => self.drag_move(this))
			.on("end",  () => self.update_target_coordinates());;
		var dragtop = d3.drag()
			.on("drag", () => self.drag_resize_top(this))
			.on("end",  () => self.update_target_coordinates());
		var dragbottom = d3.drag()
			.on("drag", () =>{ self.drag_resize_bottom(this)})
			.on("end",  () => self.update_target_coordinates());
		var newg = this.svg_g.append("g")
		this.dragrect = newg.append("rect").data([this.bar_properties])
	      	.attr("fill-opacity", .5)
	    	.attr("fill", "lightgray")
	      	.attr("cursor", "grab")
	      	.call(drag);
	    this.dragbartop  = this.newDragBar(newg,dragtop);
	    this.dragbarbottom = this.newDragBar(newg,dragbottom);
	    this.refresh_drag(0);

	}

	newDragBar(newg, callback){
		return newg.append("rect").data([this.bar_properties])
	    .attr("x",   d   => d.x + (d.dragbarw/2) )
	    .attr("width",d =>  d.width - d.dragbarw)
	    .attr("height", d =>d.dragbarw)
	    .attr("fill", "darkgray")
	    .attr("fill-opacity", 1)
	    .attr("cursor", "row-resize").call(callback)
	}

	drag_resize_top(d){
		var _drag ;
		var bp = this.bar_properties;
		this.dragbartop.each(d2 => _drag = d2.y);
		var new_y = Math.max(0, Math.min(_drag + bp.height - (bp.dragbarw / 2), d3.event.y)); 
     	var height = bp.height + (_drag - new_y);
        bp.height = height;
      	bp.y = new_y;
        this.refresh_range(0)
	}

	drag_resize_bottom(d){
		var _drag ;	
		var bp = this.bar_properties;
		this.dragbarbottom.each(d2 => _drag = d2.height);
		var largest_height = this.bar_size - bp.y - bp.dragbarw / 2;
		var height = _drag +  d3.event.dy ;
		height     = Math.max(5,Math.min(height, largest_height));
		//     = Math.min(height, largest_height); 
     	bp.height =  height ;
     	this.refresh_drag(0);
	}

	update_target_coordinates(){
		this.dragrect.attr("cursor", "grab");
		var end = this.bar_properties.y + this.bar_properties.height;
		var tmp_start = this.scale.invert(this.bar_properties.y) ;
	    var tmp_end   = this.scale.invert(end ) ;
	    var domain = this.status.y_scores_domain
	    this.bar_properties.height = end;
	    this.status.setScoreRange([tmp_start, tmp_end]);
	}

	drag_move(d) {
		var _drag ;
		this.dragrect.attr("cursor", "grabbing");
		this.dragrect.each(function(d, i){
		 	_drag = d.y;
		 });
		var new_y = d3.event.dy + _drag;
		new_y = Math.max(0, Math.min(this.bar_size - this.bar_properties.width, new_y))
      	this.bar_properties.y = new_y;
        this.refresh_range(0)

  	}




}


window.RegionScoreAxis = RegionScoreAxis;