class Axis{
	constructor(svg_g, scale, axis){
		this.svg_g = svg_g;
		this.scale = scale;
		this._d3axis = axis;
		this.axis = this._d3axis(this.scale);
		this.axis_g = svg_g.append("g");
		this.axis_g.call(this.axis);
		
	}

	idled() { 
 		this.idleTimeout = null; 
 	}

 	translate(x,y){
 		this.svg_g.attr("transform", "translate(" + x+ "," + y+ ")");
 	}
}
class RegionAxis extends Axis{
	constructor(svg_g, scale){
		super(svg_g, scale, d3.axisTop);
		this.axis_g.attr("class", "x axis");
	}

	enable_zoom_brush(max_val, target){
		var self = this;
		this._max_val = max_val;
		this.brush = d3.brushX()       
      	.extent( [ [0, -30], [target.plot_width,0] ] ) //This are absolute coordinates
      	.on("end", function(){
      		var extent = d3.event.selection
    		if(!extent){
      			if (!self.idleTimeout){
      				return self.idleTimeout = setTimeout(self.idled.bind(self), 350); 
      			};
      			target.setRange([0, self._max_val]);
    		}else{
    			var round_to  = 100000;
	    		var tmp_start = Math.round(self.scale.invert(extent[0])/ round_to ) * round_to ;
	    		var tmp_end   = Math.round(self.scale.invert(extent[1])/round_to  ) * round_to ;
	    		target.setRange([tmp_start, tmp_end])
	      		self.svg_g.select(".brush").call(self.brush.move, null); // self remove the grey brush area as soon as the selection has been done
	    	}
    	}); 
	
	    this.svg_g.append("g")
	      .attr("class", "brush")
	      .call(this.brush);
	}

	_width(){
		var full_range = this.scale.range();
		return full_range[1] - full_range[0];
	}

	update_target_coordinates(target){
		var round_to  = 100000;
		var end = this.bar_properties.x + this.bar_properties.width;
		var tmp_start = Math.round(this.scale.invert(this.bar_properties.x)/ round_to ) * round_to ;
	    var tmp_end   = Math.round(this.scale.invert(end )/round_to  ) * round_to ;
	    target.setRange([tmp_start, tmp_end]);
	}

	enable_region_highlight(target){
		var self = this;
		this.bar_properties = {x: 0, y: -8, width: this._width(), height: 16}
		
		var drag = d3.drag()
		.on("drag", function () {
         	self.dragmove(this);})
		.on("end", function(){
			console.log("end")
		 	self.dragrect.each(function(d, i){
		 		console.log(d);
		 		self.update_target_coordinates(target);
		 	});
		 	
		 });

		
      	var newg = this.svg_g.append("g")
		.data([this.bar_properties]);
      	this.dragrect = newg.append("rect")
      	.attr("x", function(d) { return 0; })
      	.attr("y", function(d) { return d.y; })
      	.attr("height", function(d){return d.height})
      	.attr("width",  function(d){return d.width})
      	.attr("fill-opacity", .3)
      	.attr("cursor", "move")
      	.call(drag);
	}

	dragmove(d) {
		var self = this;
		this.dragrect.each(function(d, i){
		 		self._start_drag_x = d.x;
		 });
		var new_x = d3.event.dx + this._start_drag_x;
		new_x = Math.max(0, Math.min(this._width() - this.bar_properties.width, new_x))
      	this.bar_properties.x = new_x;
      	this.dragrect.data([this.bar_properties])
          .attr("x", function(d){return d.x} )
      /*dragbarleft 
          .attr("x", function(d) { return d.x - (dragbarw/2); })
      dragbarright 
          .attr("x", function(d) { return d.x + width - (dragbarw/2); })*/
  }
  

	refresh_range(){
		this.axis_g.transition().duration(1000).call(d3.axisTop(this.scale));
	}
}

class GenomesAxis extends Axis{
	constructor(svg_g,scale){
		super(svg_g, scale, d3.axisLeft);
		this.axis_g.attr("class", "y axis");
	}

}

window.GenomesAxis=GenomesAxis;
window.RegionAxis = RegionAxis;