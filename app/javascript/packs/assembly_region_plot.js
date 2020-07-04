import "./region_plot";
class AssemblyRegionPlot extends RegionPlot{
	constructor(svg_g, x, y, status){
		super(svg_g, x, y, status);
		this.svg_highlight_coordinate = svg_g.append("g");
		this.highlight_line  = this.svg_highlight_coordinate.append("line").style("stroke", "red"); 
		this.highlight_label = this.svg_highlight_coordinate.append("text");//.style("stroke", "red") 
		
		this.svg_coord_block = svg_g.append("g");

		this.updatePositionLine(0);
	}

	mouseover(coords){
		this.updatePositionLine(0);
		this.updateCoords(0);
		//console.log(this.status);
	}

	click(coords){
		this.updatePositionLine(0);
	}

	
	updateCoords(duration){
		var self = this;
		var max_range = self.x.range[1];
		this.svg_coord_block.selectAll("*").remove();
		this.svg_coord_block.selectAll(".asm_map_coord")
		.data(this.status.mapped_coords, d=>d.id)
		.join(
			enter => enter.append("rect")
				.attr("height", self.y.bandwidth())
	      		.attr("class","mapped_asm_block")
	      		.attr("x", d =>  self.x(Math.max(0,d.start)))
	       		.attr("y", d =>  self.y(d.assembly))
	    	    .attr("width", d => Math.max(1,self.x(d.end) - self.x(d.start)))
	    	    .style("fill", "white"),
	    	exit   => exit.remove()
	 	       	//.on("end",self.status.end_transition.bind(self.status))
			)
	}

	updatePositionLine(duration){

		var x = this.x(this.status.position);
		var step = this.y.step();
		var asm = this.status.assembly;

		var y =  asm ?  this.y(asm) + (this.y.step()/2) : 0;
		var y_range = this.y.range();
		var number = d3.format(",.5r")(this.status.position);
		var self = this;
		
		requestAnimationFrame(function(){
				self.highlight_line
				.transition()
				.duration(duration)          
				.attr("x1", x)     
				.attr("y1", 0)      
				.attr("x2", x)     
				.attr("y2", y_range[1]); 

				self.highlight_label
				.transition()
				.duration(duration)           
				.text(number)
				.attr("x", x + 10)
				.attr("y", y)

			}
		);

	}


}

window.AssemblyRegionPlot = AssemblyRegionPlot;