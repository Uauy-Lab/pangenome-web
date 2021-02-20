class Axis{
	constructor(svg_g, scale, axis, status){
		this.svg_g = svg_g;
		this.background_rect = this.svg_g.append("rect");
		
		this.background_rect.attr("class", "axis-rect");
		this.scale = scale;
		this._d3axis = axis;
		this.axis = this._d3axis(this.scale);
		this.axis_g = svg_g.append("g");
		this.axis_g.call(this.axis);
		this.status = status;
		this.svg_g.node().classList.add("unselectable");
	}

	idled() { 
 		this.idleTimeout = null; 
 	}

 	translate(x,y){
 		this.offset_x = x;
 		this.offset_y = y;
 		this.svg_g.attr("transform", "translate(" + x+ "," + y+ ")");

 		this.translateRect();
 	}

 	event_overlap(){
 		var self = this;
		var elem = document.elementsFromPoint(d3.event.clientX, d3.event.clientY);
		var local_class = this.background_rect.attr("class");
		elem = elem.filter(e => e.classList.contains(local_class));
		return elem.length > 0;
 	}

}
class RegionAxis extends Axis{
	constructor(svg_g, scale, target, status){
		console.log("REgion axis...")
		console.log(target);
		super(svg_g, scale, d3.axisTop, status);
		this.axis_g.attr("class", "x axis");
		this.target = target;
	}

	translateRect(){

	}

	enable_zoom_brush(max_val, target, status){
		this.background_rect.attr("class", "brush-x-rect");
		var self = this;
		this._max_val = max_val;

		this.brush = d3.brushX()       
      	.extent( [ [0, -30], [target.plot_width,0] ] ) //This are absolute coordinates
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
	    	target.setRange(newRange);
    	}); 
	
	    this.axis_g.append("g")
	      .attr("class", "brush")
	      .call(this.brush);
	}

	_width(){
		var full_range = this.scale.range();
		return full_range[1] - full_range[0];
	}
	

	update_target_coordinates(){
		var round_to  = 1000000;
		var end = this.bar_properties.x + this.bar_properties.width;
		var tmp_start = Math.round(this.scale.invert(this.bar_properties.x)/ round_to ) * round_to ;
	    var tmp_end   = Math.round(this.scale.invert(end )/round_to  ) * round_to ;
	    this.target.setRange([tmp_start, tmp_end]);
	}

	
	refresh_range(duration){
		this.axis_g.transition().duration(duration).call(d3.axisTop(this.scale));
	}
}

class GenomesAxis extends Axis{

	constructor(svg_g,scale, status){
		super(svg_g, scale, d3.axisLeft, status);
		this.axis_g.attr("class", "y axis");
		this.background_rect.attr("class", "y-rect");
		this.highlight_rect = svg_g.append("rect").attr("class", "y-select");
		this.svg_g.node().classList.add("pointer");
		
	}

	translate(x,y){
		super.translate(x,y);
		this.update_rect();
	}

	update_rect(asm){
		var h = 0;
		var y = 0;
		if(asm){
			h = this.scale.step()
			y = this.scale(asm)
		}
		this.highlight_rect
		.attr("x", - this.offset_x)
		.attr("y", y)
		.attr("width", this.offset_x)
		.attr("height", h);
	}

	click(coords){
		if(coords.x >= 0 || this.status.lock ) return;
		var asm = coords.asm;
		if(this.status.assembly == asm){
			asm  =undefined;
			this.status.selected_blocks.length = 0;
			this.status.assembly = undefined;
			this.target.clearHighlight();
		}else{
			blocks = this.target.setBaseAssembly(asm);
			this.status.frozen = false;
		}
		this.update_rect(asm);		
		this.status.assembly = asm;
	}

	mouseover(){
		//if(!this.event_overlap()) return;
		//	var asm = this.asmUnderMouse();
		
	}

	enable_click(target){
		this.target = target;
		//this.svg_g.on("click", this.click.bind(this));
	}

	translateRect(){
		this.background_rect
		.attr("x", - this.offset_x)
		.attr("y", 0)
		.attr("width", this.offset_x)
		.attr("height", this.scale.range()[1]);
	}

	refresh_range(duration){
		this.axis_g.transition().duration(duration).call(d3.axisLeft(this.scale));
	}



}

window.GenomesAxis=GenomesAxis;
window.RegionAxis = RegionAxis;