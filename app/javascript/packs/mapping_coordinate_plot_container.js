class MappingCoordinatePlotContainer extends PlotContainer{
	#g_axis;
	#g_mapping;
	#g_mapped_blocks;
	#mapping_region_set;
	#axis_x;
	#axis_map;
	#label_size;
	constructor(svg_g,width,height,offset_x,offset_y, current_status){
		super(svg_g,width,height,offset_x,offset_y, current_status);
		this.#g_axis          = this.g.append("g");
		this.#g_mapping       = this.g.append("g");
		this.#g_mapped_blocks = this.g.append("g");
		this.#axis_x = new Map();
		this.#axis_map = new Map();
		this.#label_size = 150;
	}

	get label_size(){
		return this.#label_size;
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
		let rect_height = this.y.bandwidth()/3;
		console.log("updateeee");
		this.prepareScales();
		this.updateAxis();
		this.updateMappedBlocks(this.#mapping_region_set.mapping_blocks, 0);
		this.updateMappedBlocks(this.#mapping_region_set.data, rect_height/3);
	}

	region_width(region, min_width){
		let tmp_x = this.#axis_x.get(region.chromosome);
		let width = tmp_x(region.end) - tmp_x(region.start);
		return width > min_width ?  width:min_width;
	}

	region_x(region){
		let tmp_x = this.#axis_x.get(region.chromosome);
		return tmp_x(region.start)
	}

	moveMappedBlocks(update, duration, min_width, rect_height, offset){
		return update
		.transition()
		.duration(duration)
		.attr("height", rect_height)
		.attr("width", d => this.region_width(d, min_width))
		.attr("y", d => this.y(d.chromosome) + offset )
		.attr("x", d => (this.label_size + this.region_x(d)))
	}

	updateMappedBlocks(data, offset){

		console.log("mappingBlocks....")
		console.log(data)
		let self = this;
		let duration = 1000;
		let rect_height = this.y.bandwidth()/3;
		this.#g_mapping
		.selectAll(".aln_map")
		.data(data, d=>d.id)
		.join(
			(enter) =>
				enter
				.append("rect")
				.attr("block_no", d => d.block_no)
				.attr("region", d => d.id)
				.call(enter => self.moveMappedBlocks(enter, 0, 3, rect_height, offset)),
			(update) => 
				update.call(update => this.moveMappedBlocks(update, duration, 3, rect_height))
		);
	}

	updateAxis(){
		console.log("updateAxis...")
		
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
					tmp_axis.move(self.label_size,self.y(d.chromosome));
				})}
			,
			(update) => {
				update.each(function(d) {
					tmp_axis = self.axis_map.get(d.chromosome);
					tmp_axis.move(self.label_size,self.y(d.chromosome));
				})
			}
			
		)


	}




}
window.MappingCoordinatePlotContainer = MappingCoordinatePlotContainer;