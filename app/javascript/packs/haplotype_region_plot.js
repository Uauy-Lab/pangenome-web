import "./region_plot";
class HaplotypeRegionPlot extends RegionPlot{

	constructor(svg_g, x, y, color, status){
		super(svg_g, x, y, status);
		// console.log("Set up hrp");
		// console.log(x);
		this.mouseover_blocks   = [];
		this.svg_plot_elements = svg_g;
		this.svg_chr_rects  = this.svg_plot_elements.append("g");
		this.svg_main_rects = this.svg_plot_elements.append("g");
		this.svg_feature_rects = this.svg_plot_elements.append("g");
		this.color = color;
		
	}

	get blocks(){
		return this._blocks ;
	}

	set blocks(newBlocks){
		var self = this;
		this.previous_x.range( this.x.range());
		this.previous_x.domain(this.x.domain());
		this._blocks = newBlocks;
		this.clearHighlight();
		this.update(0);
	}

	update(duration){
		this.updateBlocks(duration);
		this.updateChromosomes(duration);
		this.updateFeatures(duration);
		super.update_coords();
		this.colorPlot();
	}	

	event_coordinates(event, coordinates){
		var coords  = d3.clientPoint(this.svg_chr_rects.node(), event);
		this.status.coordinates.coords  = coords;
		var eachBand = this.y.step();
		var index = Math.round(((coords + 0.5* eachBand )/ eachBand)) - 1;
		this.status.coordinates.asm     = this.y.domain()[index];
		var blocks_ret = this.blocksUnderMouse(event);
		var blocks = blocks_ret.blocks;
		this.status.coordinates.blocks  = blocks;
		if(blocks_ret.asm){ 
			this.status.coordinates.asm = blocks_ret.asm;
		}
		this.status.coordinates.in_plot   = coords[0] > 0 && coords[1] > 0
		this.status.coordinates.in_y_axis = coords[0] < 0 && coords[1] > 0
		this.status.coordinates.hash = this.blocks_hash(blocks, index);
		return this.status.coordinates;
	}

	blocks_hash(blocks, asm_index){
		return  (asm_index +1) ^ blocks
		.sort()
		.reduce( (acc, curr, idx) => {
			let tmp = curr << (idx  % 32) ;
			return acc ^ tmp }  
			, 0);
	}

	blocks_changed(coords){
		if(this.prev_block_hash === undefined){
			return true;
		}
		
		return  coords.hash != this.prev_block_hash;
	}

	mouseover(coords){
		if( this.blocks_changed(coords) ){
			var blocks = this.mouseOverHighlight(coords);
			this.prev_block_hash = this.blocks_hash(coords.blocks);
		}
	}

	updateChromosomes(duration){
		var self = this;
		var max_range = self.x.range[1];
		var data = [];
		if(this._blocks){
			data = this.blocks.displayChromosomes(this.status);
		}
		console.log(data);
		this.svg_chr_rects.selectAll(".chr_block")
		.data(data, d=>d.assembly)
		.join(
			enter => enter.append("rect")
				.attr("height", self.y.bandwidth())
	      		.attr("class","chr_block")
	      		.attr("asm", d => d.assembly)
	      		.attr("x", d =>  self.previous_x(0))
	       		.attr("y", d =>  self.y(d.assembly))
	    	    .attr("width", d => self.previous_x(d.end) - self.previous_x(d.start))
	    	    .style("fill", "Gainsboro")
				//.style("stroke", "darkgray")
				//.style("stroke-width", 1)
				//.style("stroke-dasharray", "4")
				,
	    	update => update.transition()
	    		.duration(duration)
	       		.attr("width", function(d) { 
	       			var tmp = self.x(d.end);
	 	       		return tmp < 0 ? 0:  tmp > max_range ? max_range : tmp ;	
	 	       	})
	 	       	.attr("y", d =>  self.y(d.assembly))
			)
	}

	click(coords){
		if(this.status.frozen){
			this.status.highlighted_blocks = this.mouseOverHighlight(coords);			
		}else{
			this.status.highlighted_blocks = [];
			this.setBaseAssembly(this.status.assembly);	
		}

	}

	highlightFeatures(update, duration ){
		return update
			.attr("fill", d =>
				d.search_feature == this.status.region_feature_set.highlight ?
				 "black" : "darkblue" );
	}

	updateFeatures(duration){
		var rfs = this.status.region_feature_set;
		var features = rfs.regions;
		var self = this;
		this.svg_feature_rects.selectAll(".feature-in-plot")
		.data(features, d => d.id)
		.join(
			enter => enter.append("rect")
				.attr("height", self.y.bandwidth())
				.attr("id", d => d.id)
				.attr("feature", d => d.feature )
				.attr("class", "feature-in-plot")
				.attr("search-feature", d => d.search_feature )
				.attr("x", d => self.previous_x(d.start))
	       		.attr("y", d => self.y(d.assembly))
	    	    .attr("width", d => self.previous_x(d.end) - self.previous_x(d.start))
	 			.call(enter => self.moveBars(enter, duration, 3))
	 			.call(enter => self.highlightFeatures(enter, duration))
				,
			update => self.moveBars(update, duration, 3)
				.call(update => self.highlightFeatures(update, duration)),
	    	exit   => self.moveBars(exit  , duration, 3).remove()
			); 
	}

	moveBars(update, duration, min_width){
		var self = this;
		return update
	    	.transition()
	    	.duration(duration)
	    	.attr("x",     d =>  self.x(d.start))
	       	.attr("y",     d =>  self.y(d.assembly))
	       	.attr("width", d =>  self.x(d.end) - self.x(d.start) < min_width ? min_width : self.x(d.end) - self.x(d.start))
	       	.attr("height", self.y.bandwidth());
	}

	updateBlocks(duration){
		var self  = this;

		var hb = this.status.table_selected_bocks;
		hb = hb.length == 0 ? this.status.highlighted_blocks : hb;
		hb = hb ? hb: [];
		var data = [];
		if(this.blocks){
			 data = this.blocks.displayData(self.status);
		}
		this.svg_main_rects.selectAll(".block_bar")
		.data(data, d=>d.id)
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
	    		.call(enter => self.moveBars(enter, duration, 1))
	 	     	,
	    	update => self.moveBars(update, duration, 1),
	    	exit   => self.moveBars(exit  , duration, 1).remove()
	      );
	}

	mouseOverHighlight(coords){
		var asm = coords.asm;
		var blocks =  coords.blocks; 
		if(blocks.length > 0){
			this.setBaseAssembly(this.status.assembly);
		}
		if(blocks.length == 0){
			this.highlightBlocks(this.status.blocks_for_highlight);
			return [];			
		}		
		this.mouseover_blocks = blocks;
		this.highlightBlocks(this.mouseover_blocks);	
		
		return blocks;
	
	}

	highlightBlocks(blocks){
		var self = this;
		var bars = this.svg_main_rects.selectAll(".block_bar");
		requestAnimationFrame(
			function(){
				if(blocks.length > 0){
					bars.
					style("opacity", d => blocks.includes(d.block_no)? 1:0.1);
					var to_highlight = 	self.svg_main_rects
					.selectAll(".block_bar")
					.filter(d => blocks.includes(d.block_no))
					.moveToFront();
				}else{
					bars.
					style("opacity", 0.8);
				};
			}
		);
	}

	colorPlot(){
		var self = this;
		requestAnimationFrame(function(){
			self.svg_main_rects.selectAll(".block_bar")
			.style("fill", d => self.color(d.color_id));
		});
	}

	clearHighlight(){
		this.status.highlighted_blocks.length = 0;
		this.highlightBlocks(this.status.highlighted_blocks);
	}

	refresh_range(duration){
	    this.update(duration);
	}

	setBaseAssembly(assembly){
		let prev_asm = this._blocks.base_assembly;
		var blocks = this._blocks.setBaseAssembly(assembly);
		if(assembly == prev_asm){
			return blocks;
		}
		this.colorPlot();
		return blocks;
	}


	mouseOutHighlight(){
		if(this.status.stop_interactions){
			return;
		}
		this.mouseover_blocks.length = 0
		this.setBaseAssembly(this.status.assembly);
		this.updateDisplayFeedback(null,0)
	}

	blocksUnderMouse(event){
    	var elem = document.elementsFromPoint(event.clientX, event.clientY);
   		var blocks = elem.map(e =>  e.getAttribute("block-no")).filter(a => a);
   		var asm = elem.map( e => e.getAttribute("block-asm")).filter(a=>a);

   		blocks = blocks.map(e=>parseFloat(e));
   		return {blocks: blocks, asm: asm[0]};  
	}
}

window.HaplotypeRegionPlot = HaplotypeRegionPlot;