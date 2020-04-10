import "./haplotype_region_axis";
class DragAxis extends RegionAxis{
	constructor(svg_g, scale, target, status){
		super(svg_g, scale,target, status);
		var self = this;
		this.bar_properties = {x: 0, y: -8, width: this._width(), height: 16}
		var drag = d3.drag()
		.on("drag", function () {
         	self.dragmove(this);})
		.on("end", function(){
		 	self.update_target_coordinates(target); 	
		});

      	var newg = this.svg_g.append("g")
		.data([this.bar_properties]);
      	this.dragrect = newg.append("rect")
      	.attr("fill-opacity", .3)
      	.attr("cursor", "move")
      	.call(drag);
      	this.refresh_range();
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
  		this.bar_properties.x     = this.scale(this.status.start)
  		this.bar_properties.width = this.scale(this.status.end) - this.scale(this.status.start)
  		this.dragrect.data([this.bar_properties]).transition()
	   	.duration(500)
         .attr("x", function(d) { return d.x; })
      	.attr("y", function(d) { return d.y; })
      	.attr("height", function(d){return d.height})
      	.attr("width",  function(d){return d.width});
		
	}



}

window.DragAxis = DragAxis;