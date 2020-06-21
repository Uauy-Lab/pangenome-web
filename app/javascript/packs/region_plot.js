class RegionPlot{
	constructor(svg_g, x,y, status){
		this.y = y;
		this.x = x;
		this.previous_x = d3.scaleLinear();
		this.status = status;
		this.svg_plot_elements = svg_g;
	}

	update_coords(){
		this.previous_x.range(this.x.range());
		this.previous_x.domain(this.x.domain());
	}

}

window.RegionPlot = RegionPlot;