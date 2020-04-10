class Axis{
	constructor(svg_g, scale, axis, status){
		this.svg_g = svg_g;
		this.scale = scale;
		this._d3axis = axis;
		this.axis = this._d3axis(this.scale);
		this.axis_g = svg_g.append("g");
		this.axis_g.call(this.axis);
		this.status = status;
	}

	idled() { 
 		this.idleTimeout = null; 
 	}

 	translate(x,y){
 		this.svg_g.attr("transform", "translate(" + x+ "," + y+ ")");
 	}
}
class RegionAxis extends Axis{
	constructor(svg_g, scale, target, status){
		super(svg_g, scale, d3.axisTop, status);
		this.axis_g.attr("class", "x axis");
		this.target = target;
	}

	enable_zoom_brush(max_val, target, status){
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
	

	update_target_coordinates(){
		var round_to  = 100000;
		var end = this.bar_properties.x + this.bar_properties.width;
		var tmp_start = Math.round(this.scale.invert(this.bar_properties.x)/ round_to ) * round_to ;
	    var tmp_end   = Math.round(this.scale.invert(end )/round_to  ) * round_to ;
	    this.target.setRange([tmp_start, tmp_end]);
	}

	
	refresh_range(){
		this.axis_g.transition().duration(500).call(d3.axisTop(this.scale));
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