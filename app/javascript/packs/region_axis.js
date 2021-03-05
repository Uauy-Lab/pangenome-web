class RegionAxis extends Axis{
	constructor(svg_g, scale, target, status, orientation ){
		console.log("REgion axis...")
		console.log(target);
		console.log(orientation);
		super(svg_g, scale, d3.axisTop, status);
		if(!orientation){
			this.orientation = "x"
		}else{
			this.orientation = orientation;
		}

		this.axis_g.attr("class", this.orientation + " axis");
		this.target = target;
	}

	translateRect(){

	}

	enable_zoom_brush(max_val){
		this.background_rect.attr("class", "brush-" +  this.orientation + " -rect");
		var self = this;
		this._max_val = max_val;

		this.brush = d3.brushX()       
      	.extent( [ [0, -30], [self.target.plot_width,0] ] ) //This are absolute coordinates
      	.on("end", function(){
      		var extent = d3.event.selection
      		var newRange = [0, max_val];
    		if(!extent){
      			if (!self.idleTimeout){
      				return self.idleTimeout = setTimeout(self.idled.bind(self), 350); 
      			}
    		}else{
	    		newRange[0]   = self.status.round(extent[0]) ;
	    		newRange[1]   = self.status.round(extent[1]) ;
	      		self.svg_g.select(".brush").call(self.brush.move, null); // self remove the grey brush area as soon as the selection has been done
	    	}
	    	console.log(self);
	    	self.status.setRange(newRange);
    	}); 
	
	    this.axis_g.append("g")
	      .attr("class", "brush")
	      .call(this.brush);
	}

	_width(){
		var full_range = this.scale.range();
		return full_range[1] - full_range[0];
	}
		
	refresh_range(duration){
		if(this.orientation == "x"){
			this.axis_g.transition().duration(duration).call(d3.axisTop(this.scale));
		}else if(this.orientation == "y"){
			this.axis_g.transition().duration(duration).call(d3.axisLeft(this.scale));
		}else{
			console.error("Axis orientation must be x or y");
			console.trace();
		}
	}


}


window.RegionAxis = RegionAxis;