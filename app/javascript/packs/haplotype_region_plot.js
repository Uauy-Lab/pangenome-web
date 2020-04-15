class HaplotypeRegionPlot{

	constructor(svg_g, x, y, color, current_status){
		this.highlighted_blocks = [];
		this.mouseover_blocks   = [];
		this.svg_plot_elements = svg_g;
		this.svg_chr_rects  = this.svg_plot_elements.append("g");
		this.svg_main_rects = this.svg_plot_elements.append("g").append("g");
		this.y = y;
		this.x = x;
		this.previous_x = d3.scaleLinear();
		this.color = color;
		this.bars = this.svg_main_rects.selectAll(".block_bar");
		this.current_status = current_status;

	}

	get blocks(){
		return this._blocks;
	}

	set blocks(newBlocks){
		var self = this;
		this.previous_x.range(this.x.range());
		this.previous_x.domain(this.x.domain());
		this._blocks = newBlocks;
		this.clearHighlight();
		this.update(0);
	}

	update(duration){
		this.updateBlocks(duration);
		this.updateChromosomes(duration);
		this.previous_x.range(this.x.range());
		this.previous_x.domain(this.x.domain());
		this.colorPlot();;
	}	

	updateChromosomes(duration){
		var self = this;
		var max_range = self.x.range[1];
		this.svg_chr_rects.selectAll(".chr_block")
		.data(this._blocks.chromosomes_lengths, d=>d.assembly)
		.join(
			enter => enter.append("rect")
				.attr("height", self.y.bandwidth())
	      		.attr("class","chr_block")
	      		.attr("x", d =>  self.previous_x(0))
	       		.attr("y", d =>  self.y(d.assembly))
	    	    .attr("width", d => self.previous_x(d.end) - self.previous_x(d.start))
	    	    .style("fill", "lightgray"),
	    	update => update.transition()
	    		.duration(duration)
	       		.attr("width", function(d) { 
	       			var tmp = self.x(d.end);
	 	       		return tmp < 0 ? 0:  tmp > max_range ? max_range : tmp ;	
	 	       	})
			)
	}

	moveBars(update, duration){
		var self = this;
		return update
	    	.transition()
	    	.duration(duration)
	    	.attr("x",     d =>  self.x(d.start))
	       	.attr("y",     d =>  self.y(d.assembly))
	       	.attr("width", d =>  self.x(d.end) - self.x(d.start));
	}

	updateBlocks(duration){
		var self  = this;
		var hb = self.highlighted_blocks;
		this.svg_main_rects.selectAll(".block_bar")
		.data(this._blocks.displayData(), d=>d.id)
		.join(
			enter => 
				enter.append("rect")//.attr("class","block_rect")
	      		.attr("height", self.y.bandwidth())
	      		.attr("class","block_bar")
	      		.attr("block-no", d => d.block_no)
	      		.attr("block-asm",d => d.assembly)
	      		.attr("x", d => self.previous_x(d.start))
	       		.attr("y", d => self.y(d.assembly))
	    	    .attr("width", d => self.previous_x(d.end) - self.previous_x(d.start))
	 	       	.style("opacity", d => hb.length==0? 1:hb.includes(d.block_no)? 1:0.1)
	       		.on("mousemove",  d	=> self.mouseOverHighlight(d3.event, d))
	       		.on("mouseout",   d => self.mouseOutHighlight(d))
	       		.on("click", function(d){
	       			self.current_asm = d.assembly;
	       			self.setBaseAssembly(d.assembly);
	    		})
	    		.call(enter => self.moveBars(enter, duration))
	 	     	,
	    	update => self.moveBars(update, duration),
	    	exit   => self.moveBars(exit  , duration).remove()
	      );
	}

	mouseOverHighlight(event,d){
		var self = this;
		if(d.assembly != this.tmp_asm){
			this.tmp_asm = d.assembly;
			this.setBaseAssembly(d.assembly);
		}
		var blocks =  this.blocksUnderMouse(event); 
		var b_new  = blocks.filter(x => !self.mouseover_blocks.includes(x));
		var b_lost = this.mouseover_blocks.filter(x => !blocks.includes(x));
		if(b_new.length + b_lost.length > 0) {
			this.mouseover_blocks = blocks;
			this.highlightBlocks(this.mouseover_blocks);	
		}
		blocks = this._blocks.filter_blocks(blocks);
	}

	highlightBlocks(blocks){
		var self = this;
		var bars = this.svg_main_rects.selectAll("rect");
		if(blocks.length > 0){
			bars.transition().
			duration(500).
			style("opacity", d => blocks.includes(d.block_no)? 1:0.1);	
		}else{
			bars.
			transition().
			duration(500).
			style("opacity", 0.8);
		}
	}

	colorPlot(){
		var self = this;
		var bars = this.svg_main_rects.selectAll("rect");
		bars.style("fill", function(d) { 
			return self.color(d.color_id); 
		});
	}

	clearHighlight(){
		this.current_asm = "";
		this.highlighted_blocks.length = 0;
		this.highlightBlocks(this.highlighted_blocks);
	}

	refresh_range(duration){
		var self = this;
	    this.update(duration);
	}

	setBaseAssembly(assembly){
		var asm_blocks = this._blocks.setBaseAssembly(assembly);
		this.colorPlot();
		this.highlightBlocks(asm_blocks);
		this.highlighted_blocks = asm_blocks;
	}

	mouseOutHighlight(haplotype_region){
		this.mouseover_blocks.length = 0
		this.highlightBlocks(this.highlighted_blocks);
	}

	blocksUnderMouse = function(event){
    	var elem = document.elementsFromPoint(event.clientX, event.clientY);
   		var blocks = elem.map(e =>  e.getAttribute("block-no")).filter(a => a);
   		blocks = blocks.map(e=>parseFloat(e));
   		return blocks; 
	}
}

window.HaplotypeRegionPlot = HaplotypeRegionPlot;