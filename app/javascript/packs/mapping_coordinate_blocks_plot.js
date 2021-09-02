import "./region_plot";
class HaplotypeRegionPlot extends RegionPlot {
	constructor(svg_g, x, y, status) {
	  super(svg_g, x, y, status);
	  this.mouseover_blocks = [];
	  this.svg_plot_elements = svg_g;
	  this.svg_chr_rects = this.svg_plot_elements.append("g");
	  this.svg_main_rects = this.svg_plot_elements.append("g");
	//   this.svg_feature_rects = this.svg_plot_elements.append("g");
	//   this.color = color;
	}
}