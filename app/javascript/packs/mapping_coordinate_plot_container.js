class MappingCoordinatePlotContainer extends PlotContainer{
	#g_axis;
	#g_mapping;
	#g_mapped_blocks;
	#mapping_region_set;

	constructor(svg_g,width,height,offset_x,offset_y, current_status){
		super(svg_g,width,height,offset_x,offset_y, current_status);
		this.#g_axis          = this.g.append("g");
		this.#g_mapping       = this.g.append("g");
		this.#g_mapped_blocks = this.g.append("g");
	}

	set mapping_region_set(mprs){
		this.#mapping_region_set = mprs;
	}

	update(){
		this.updateAxis();
	}

	updateAxis(){
		this.y.domain(this.#mapping_region_set.chromosomes)
		this.x.domain([0,this.#mapping_region_set.longest])
		let data = this.#mapping_region_set.chromosome_regions;
		console.log(data);
		var duration = 100;
		this.#g_axis
		.selectAll(".chr_labels")
		.data(data)
		.join(
        (enter) =>
          enter
            .append("text")
            .attr("height", this.y.bandwidth())
            .attr("class", "chr_block")
            .attr("asm", d => d.chromosome)
            .attr("y",   d =>  this.y(d.chromosome))
            .text(d => d.chromosome)
            .style("fill", "Gainsboro"),
        //.style("stroke", "darkgray")
        //.style("stroke-width", 1)
        //.style("stroke-dasharray", "4")
        (update) =>
          update
            .transition()
            .duration(duration)
            .attr("width", function (d) {
              var tmp = self.x(d.end);
              return tmp < 0 ? 0 : tmp > max_range ? max_range : tmp;
            })
            .attr("y", (d) => self.y(d.assembly))
      );

	}




}
window.MappingCoordinatePlotContainer = MappingCoordinatePlotContainer;