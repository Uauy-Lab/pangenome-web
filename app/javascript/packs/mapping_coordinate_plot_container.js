class MappingCoordinatePlotContainer extends PlotContainer{
	#g_axis;
	#g_mapping;
	#g_mapped_blocks;
	#mapping_region_set;
	#axis_x;
	#axis_map;
	constructor(svg_g,width,height,offset_x,offset_y, current_status){
		super(svg_g,width,height,offset_x,offset_y, current_status);
		this.#g_axis          = this.g.append("g");
		this.#g_mapping       = this.g.append("g");
		this.#g_mapped_blocks = this.g.append("g");
		this.#axis_x = new Map();
		this.#axis_map = new Map();
	}

	set mapping_region_set(mprs){
		this.#mapping_region_set = mprs;
	}

	get axis_x(){
		return this.#axis_x;
	}

	get axis_map(){
		return this.#axis_map;
	}

	prepareScales(){
		this.y.domain(this.#mapping_region_set.chromosomes);
		this.x.domain([0,this.#mapping_region_set.longest])
		let data = this.#mapping_region_set.chromosome_regions;
		let longest = this.#mapping_region_set.longest;
		let x = this.x;
		data.forEach(region => {
			if(!this.#axis_x.has(region.chromosome)) {
				this.#axis_x.set(region.chromosome, d3.scaleLinear());
			}
			let tmp_x = this.#axis_x.get(region.chromosome);
			tmp_x.rangeRound(x.range());
			tmp_x.domain([region.start, region.start + longest]);
		});
		console.log(this.#axis_x);
	}

	update(){
		
		this.prepareScales();
		this.updateAxis();
	}

	updateMappedBlocks(){

	}

	updateAxis(){
		
		
		let data = this.#mapping_region_set.chromosome_regions;
		var duration = 100;
		let self = this;
		this.#g_axis
		.selectAll(".chr_labels")
		.data(data, d=>d.chromosome)
		.join(
        (enter) =>
          enter
            .append("text")
            .attr("height", this.y.bandwidth())
            .attr("asm", d => d.chromosome)
            .attr("y",   d =>  this.y(d.chromosome))
            .text(d => d.chromosome)
        ,
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
	
		this.#g_axis.selectAll(".chr_axis")
		.data(data, d=>chromosome)
		.join(
			(enter) => {
				enter.each(function(d) {
					let tmp_g =d3.select(this).append("g")
					let tmp_axis = new RegionAxis(tmp_g, self.axis_x.get(d.chromosome), null, self.status, "x" );
					self.axis_map.set(d.chromosome, tmp_axis);
					tmp_axis.move(150,self.y(d.chromosome));
				})}
			,
			(update) => {
				update.each(function(d) {
					tmp_axis = self.axis_map.get(d.chromosome);
					tmp_axis.move(150,self.y(d.chromosome));
				})
			}
			
		)


	}




}
window.MappingCoordinatePlotContainer = MappingCoordinatePlotContainer;