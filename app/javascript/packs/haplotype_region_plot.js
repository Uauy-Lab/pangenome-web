class HaplotypeRegionPlot{

	constructor(svg_g, x, y, color, current_status){
		this.highlighted_blocks = [];
		this.mouseover_blocks   = [];
		this.svg_plot_elements = svg_g;
		this.svg_chr_rects  = this.svg_plot_elements.append("g");
		this.svg_main_rects = this.svg_plot_elements.append("g");
		this.svg_highlight_coordinate = this.svg_plot_elements.append("g");
		this.y = y;
		this.x = x;
		this.previous_x = d3.scaleLinear();
		this.color = color;
		this.current_status = current_status;
		this.setupDisplayFeedbaack();
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

	updateDisplayFeedback(event,position){
		var y = 0;
		if(event){
			var asm = this.asmUnderMouse(event);
			var y = this.y(asm) + (this.y.step()/2);
		}
		var y_range = this.y.range();
		this.highlight_line          
	  	.attr("x1", position)     
	    .attr("y1", 0)      
	    .attr("x2", position)     
	    .attr("y2", y_range[1]); 
        var number = d3.format(",.5r")(this.x.invert(position));
        this.highlight_label
        .attr("x", position + 10)
        .attr("y", y)
        .text(number);
	}

	setupDisplayFeedbaack(){
		this.svg_plot_elements
		.on("mousemove", () => this.mouseover(d3.event))
		.on("mouseout",  () => this.mouseOutHighlight())
		this.highlight_line  = this.svg_highlight_coordinate.append("line").style("stroke", "red") 
		this.highlight_label = this.svg_highlight_coordinate.append("text")//.style("stroke", "red") 
		this.updateDisplayFeedback(null,0);
	}

	mouseover(event){
		var new_x = event.clientX - this.current_status.margin().left;
		var y_offset = this.current_status.margin().top;
		this.updateDisplayFeedback(event, new_x);
		this.mouseOverHighlight(event)
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
	      		.attr("asm", d => d.assembly)
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
		console.log(this);
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

	mouseOverHighlight(event){
		var self = this;
		var asm = this.asmUnderMouse(event);
		var blocks =  this.blocksUnderMouse(event); 
		if(blocks.length == 0){
			if(this.highlighted_blocks){
				this.highlightBlocks(this.highlighted_blocks);
			}
			return;			
		}
		if(asm != this.tmp_asm){
			this.tmp_asm = asm;
			var tmp_blocks = this.setBaseAssembly(asm);
			if(tmp_blocks){
				this.highlighted_blocks = tmp_blocks;	
			}
			
		}
		var b_new  = blocks.filter(x => !self.mouseover_blocks.includes(x));
		var b_lost = this.mouseover_blocks.filter(x => !blocks.includes(x));
		if(b_new.length + b_lost.length > 0) {
			this.mouseover_blocks = blocks;
			this.highlightBlocks(this.mouseover_blocks);	
		}
	
	}

	highlightBlocks(blocks){
		var self = this;
		var bars = this.svg_main_rects.selectAll(".block_bar");
		if(blocks.length > 0){
			bars.transition().
			duration(0).
			style("opacity", d => blocks.includes(d.block_no)? 1:0.1);
			to_highlight = 	this.svg_main_rects
			.selectAll(".block_bar")
			.filter(d => blocks.includes(d.block_no))
			.moveToFront();
		}else{
			bars.
			transition().
			duration(0).
			style("opacity", 0.8);
		}
	}

	colorPlot(){
		this.svg_main_rects.selectAll(".block_bar")
		.style("fill", d => this.color(d.color_id));
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

	mouseOutHighlight(){
		this.mouseover_blocks.length = 0
		this.highlightBlocks(0);
		this.updateDisplayFeedback(null,0)
	}

	blocksUnderMouse = function(event){
    	var elem = document.elementsFromPoint(event.clientX, event.clientY);
   		var blocks = elem.map(e =>  e.getAttribute("block-no")).filter(a => a);
   		blocks = blocks.map(e=>parseFloat(e));
   		return blocks; 
	}

	asmUnderMouse = function(event){
    	var elem = document.elementsFromPoint(event.clientX, event.clientY);
   		var asm = elem.map(e =>  e.getAttribute("asm")).filter(a => a);
   		return asm[0]; 
	}
}

window.HaplotypeRegionPlot = HaplotypeRegionPlot;