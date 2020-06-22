import "./region_plot";
class AssemblyRegionPlot extends RegionPlot{
	constructor(svg_g, x, y, status){
		super(svg_g, x, y, status);
		this.svg_highlight_coordinate = svg_g.append("g");
		this.highlight_line  = this.svg_highlight_coordinate.append("line").style("stroke", "red"); 
		this.highlight_label = this.svg_highlight_coordinate.append("text");//.style("stroke", "red") 
		this.updatePositionLine(0);
	}

	mouseover(coords){
		this.updatePositionLine(0);
	}

	click(coords){
		this.updatePositionLine(0);
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