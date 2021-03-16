import "./region_axis";
class DragAxis extends RegionAxis{
	constructor(svg_g, scale, target, status){
		super(svg_g, scale,target, status);
		var self = this;
		this.bar_properties = {x: 0, y: -8, width: this.bar_size, height: 16, dragbarw:2}
		var drag = d3.drag()
			.on("drag",  () =>	self.drag_move(this))
			.on("end", ()   => self.update_target_coordinates(target));
		var dragleft = d3.drag()
			.on("drag", () => self.drag_resize_left(this))
			.on("end", () => self.update_target_coordinates(target));
		var dragrigth = d3.drag()
			.on("drag", () => self.drag_resize_right(this))
			.on("end", () =>  self.update_target_coordinates(target));
      	var newg = this.svg_g.append("g")
      	this.dragrect = newg.append("rect").data([this.bar_properties])
	      	.attr("fill-opacity", .5)
	    	.attr("fill", "lightgray")
	      	.attr("cursor", "grab")
	      	.call(drag);     
      	this.dragbarleft  = this.newDragBar(newg,dragleft);
	    this.dragbarright = this.newDragBar(newg,dragrigth);
	    this.refresh_range(0);
	}

	newDragBar(newg, callback){
		return newg.append("rect").data([this.bar_properties])
	    .attr("y",   d   => d.y + (d.dragbarw/2) )
	    .attr("height",d =>  d.height - d.dragbarw)
	    .attr("width", d =>d.dragbarw)
	    .attr("fill", "darkgray")
	    .attr("fill-opacity", 1)
	    .attr("cursor", "col-resize").call(callback)
	}

	drag_resize_left(d){
		var _drag ;
		var bp = this.bar_properties;
		this.dragbarleft.each(d2 => _drag = d2.x);
		var new_x = Math.max(0, Math.min(_drag + bp.width - (bp.dragbarw / 2), d3.event.x)); 
     	var width = bp.width + (_drag - new_x);
        bp.width = width;
      	bp.x = new_x;
        this.refresh_range(0)
	}


	drag_resize_right(d){
		var _drag ;	
		var bp = this.bar_properties;
		this.dragbarright.each(d2 => _drag = d2.width);
		var largest_width = this.bar_size - bp.x - bp.dragbarw / 2
		var width = d3.event.dx +  _drag;
		width     = Math.max(5,Math.min(width, largest_width)); 
     	bp.width =  width ;
     	this.refresh_range(0);
	}
	
	drag_move(d) {
		var _drag ;
		this.dragrect.attr("cursor", "grabbing");
		this.dragrect.each(function(d, i){
		 	_drag = d.x;
		 });
		var new_x = d3.event.dx + _drag;
		new_x = Math.max(0, Math.min(this.bar_size - this.bar_properties.width, new_x))
      	this.bar_properties.x = new_x;
        this.refresh_range(0)

  	}

  	refresh_range(duration){
  		var self = this;
  		if(duration > 0){
  			this.bar_properties.x     = this.scale(this.status.start)
  			this.bar_properties.width = this.scale(this.status.end) - this.scale(this.status.start)
  		}
  		this.axis_g.transition().duration(duration).call(d3.axisTop(this.scale));
  		
  		requestAnimationFrame(
  			function(){
		  		self.dragrect.data([self.bar_properties])
		  		.transition()
			   	.duration(duration)
		        .attr("x", function(d) { return d.x; })
		      	.attr("y", function(d) { return d.y; })
		      	.attr("height", function(d){return d.height})
		      	.attr("width",  function(d){return d.width});

		      	var d = self.bar_properties;

		      	self.dragbarleft
		      	.transition()
			   	.duration(duration)
			   	.attr("x",  d.x - (d.dragbarw/2))

		      	self.dragbarright
		      	.transition()
			   	.duration(duration)
			   	.attr("x",  d.x +  d.width - (d.dragbarw/2))
		   }
		)
	}

	 update_target_coordinates(){
		this.dragrect.attr("cursor", "grab");
		var round_to  = 1000000;
		var end = this.bar_properties.x + this.bar_properties.width;
		var tmp_start = Math.round(this.scale.invert(this.bar_properties.x)/ round_to ) * round_to ;
	    var tmp_end   = Math.round(this.scale.invert(end )/round_to  ) * round_to ;
	    this.status.setRange([tmp_start, tmp_end]);
	}



}

window.DragAxis = DragAxis;