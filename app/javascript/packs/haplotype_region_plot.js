class HaplotypeRegionPlot{

	constructor(svg_g, x, y, color){
		this.highlighted_blocks = [];
		this.mouseover_blocks   = [];
		this.svg_plot_elements = svg_g;
		this.svg_chr_rects  = this.svg_plot_elements.append("g");
		this.svg_main_rects = this.svg_plot_elements.append("g").append("g");
		this.y = y;
		this.x = x;
		this.color = color;
		this.bars = this.svg_main_rects.selectAll(".block_bar");
	}

	get blocks(){
		return this._blocks;
	}

	set blocks(newBlocks){
		console.log("changing blocks!")
		var self = this;
		this._blocks = newBlocks;
		//this.bars = this.svg_main_rects.selectAll("rect")//.data(this._blocks);
		//this.bars = this.svg_main_rects.selectAll("rect");
		//this.bars.data([]).enter().remove();
		//this.bars.data(this._blocks);
		//this.update(0)
	}

	update(duration){
		var self  = this;
		console.log("++++");
		//console.log(this.svg_main_rects)
		
		var selection = this.svg_main_rects.selectAll(".block_bar").data(this._blocks.displayData(), d=>d.id)
		.join(
			enter => 
				enter.append("rect")//.attr("class","block_rect")
	      		.attr("height", self.y.bandwidth())
	      		.attr("class","block_bar")
	      		.attr("block-no", function(d){return d.block_no;})
	      		.attr("block-asm",function(d){return d.assembly;})
	      		.attr("x", function(d) { console.log("adding X");return self.x(d.start); })
	       		.attr("y", function(d) { return self.y(d.assembly); })

	    	    .attr("width", function(d) { 
	 	       		return self.x(d.end) - self.x(d.start)
	 	       	})
	       		.on("mousemove", function(d){
	       			self.mouseOverHighlight(d3.event, d); 	
	       		})
	       		.on("mouseout",  function(d){self.mouseOutHighlight(d) ;})
	       		.on("click", function(d){
	       			self.current_asm = d.assembly;
	       			self.setBaseAssembly(d.assembly);
	    		})
	    		,
	    	update => update
	    		.attr("x", function(d) { console.log("updating X");return self.x(d.start); })
	       		.attr("y", function(d) { return self.y(d.assembly); })
	       		.attr("width", function(d) { 
	 	       		return self.x(d.end) - self.x(d.start)
	 	       	})
	     		,
	    	exit => exit.remove()
	      );
			
		// selection.enter()
	 //      	.transition()
	 //   	 	.duration(duration)
	 //      	.attr("x", function(d) { console.log("Updating X");return self.x(d.start); })
	 //      	.attr("y", function(d) { return self.y(d.assembly); })
	 //      	.attr("width", function(d) { 
	 //      		return self.x(d.end) - self.x(d.start); 
	 //      	});
	 //     selection.exit().remove();
	      	

	   //this.bars.exit().remove();
	    //console.log(this.bars);
	    this.colorPlot();
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
	}

	highlightBlocks(blocks){
		var self = this;
		var bars = this.svg_main_rects.selectAll("rect");
		if(blocks.length > 0){
			bars.transition().
			duration(500).
			style("opacity", 
				function(d) {
				 return blocks.includes(d.block_no)? 1:0.1 
				});	
		}else{
			bars.
			transition().
			duration(500).
			style("opacity", 
				function(d) { 
					return 0.8 
				});
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
		console.log(this.x.domain());
		
		 // this.svg_main_rects.selectAll(".block_bar")
	  //   	 .transition()
	  //   	 .duration(duration)
	  //     .attr("x", function(d) { return self.x(d.start);})
	  //     .attr("width", function(d) { return self.x(d.end) - self.x(d.start); });

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