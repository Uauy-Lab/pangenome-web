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

 	align_labels(aln){
 		this.axis_g.attr("text-anchor", aln);
 	}

 	get bar_size(){
		var full_range = this.scale.range();
		return full_range[1] - full_range[0];
	}

}

window.Axis = Axis;