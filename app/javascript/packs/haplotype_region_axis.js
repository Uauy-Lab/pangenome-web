class RegionAxis{
	constructor(svg_g, scale){
		this.svg_g = svg_g;
		this.scale = scale;
		this.xAxis = d3.axisTop(this.scale);	

		this.axis_g = svg_g.append("g");
		this.axis_g.attr("class", "x axis")
		.call(this.xAxis);
	}


	idled() { 
 		this.idleTimeout = null; 
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
      		};// self allows to wait a little bit
     
      		target.setRange(0, self._max_val);
    	}else{
    		var round_to  = 100000;
    		var tmp_start = Math.round(self.scale.invert(extent[0])/ round_to ) * round_to ;
    		var tmp_end   = Math.round(self.scale.invert(extent[1])/round_to )* round_to ;
    		target.setRange(tmp_start, tmp_end)
      		self.svg_g.select(".brush").call(self.brush.move, null); // self remove the grey brush area as soon as the selection has been done
    	}
    	
      }); // Each time the brush selection changes, trigger the 'updateChart' function
	
    this.svg_g.append("g")
    //.attr("transform", "translate(" + this.margin.left + ",0)")
      .attr("class", "brush")
      .call(this.brush);
	}

	refresh_range(){
		this.axis_g.transition().duration(1000).call(d3.axisTop(this.scale));
	}






}


window.RegionAxis = RegionAxis;