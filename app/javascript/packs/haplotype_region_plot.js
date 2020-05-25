class HaplotypeRegionPlot{

	constructor(svg_g, x, y, color, status){
		this.mouseover_blocks   = [];
		this.svg_plot_elements = svg_g;
		this.svg_chr_rects  = this.svg_plot_elements.append("g");
		this.svg_main_rects = this.svg_plot_elements.append("g");
		this.svg_highlight_coordinate = this.svg_plot_elements.append("g");
		this.y = y;
		this.x = x;
		this.previous_x = d3.scaleLinear();
		this.color = color;
		this.status = status;
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
		this.colorPlot();
		this.updatePositionLine(duration);
	}	


	updatePositionLine(duration){
		var x = this.x(this.status.coordinate);
		var step = this.y.step();
		var asm = this.status.selected_assembly
		var y =  asm ?  this.y(asm) + (this.y.step()/2) : 0;
		var y_range = this.y.range();
		var self = this;
		requestAnimationFrame(function(){
				self.highlight_line
				.transition()
				.duration(duration)          
				.attr("x1", x)     
				.attr("y1", 0)      
				.attr("x2", x)     
				.attr("y2", y_range[1]); 

				var number = d3.format(",.5r")(self.status.coordinate);
				self.highlight_label 
				.text(number)
				.attr("x", x + 10)
				.attr("y", y)

			}
		);

	}

	updateDisplayFeedback(event,position){
		var y = 0;
		var self = this;
		
		this.status.selected_assembly = null;
		if(event){
			var asm = this.asmUnderMouse(event);
			if(asm  && event.clientX > this.status.margin.left){
				this.status.selected_assembly = asm;
			}
			this.status.coordinate = this.x.invert(position);
		}

		this.updatePositionLine(0);
		
	}

	setupDisplayFeedbaack(){
		this.svg_plot_elements
		.on("mouseout",  () => this.mouseOutHighlight());
		this.highlight_line  = this.svg_highlight_coordinate.append("line").style("stroke", "red"); 
		this.highlight_label = this.svg_highlight_coordinate.append("text");//.style("stroke", "red") 
		this.updateDisplayFeedback(null,0);
	}

	mouseover(event){
		if(this.status.stop_interactions){
			return;
		}
		var new_x = event.clientX - this.status.margin.left;
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
	    		.on("start",self.status.start_transition.bind(self.status))
	    		.duration(duration)
	       		.attr("width", function(d) { 
	       			var tmp = self.x(d.end);
	 	       		return tmp < 0 ? 0:  tmp > max_range ? max_range : tmp ;	
	 	       	})
	 	       	.on("end",self.status.end_transition.bind(self.status))
			)
	}

	click(event){
		var new_x = event.clientX - this.status.margin.left;
		var asm = this.asmUnderMouse(event);
		if(new_x < 0 || asm === undefined ){
			return;
		}
		this.status.toggle_frozen();
		this.updateDisplayFeedback(event, new_x);
		if(this.status.frozen){
			this.status.selected_blocks = this.mouseOverHighlight(event);			
		}else{
			this.status.selected_blocks = [];
		}

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
		var hb = this.status.highlighted_blocks;
		hb = hb ? hb: [];
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
	    		.call(enter => self.moveBars(enter, duration))
	 	     	,
	    	update => self.moveBars(update, duration),
	    	exit   => self.moveBars(exit  , duration).remove()
	      );
	}

	mouseOverHighlight(event){
		//this.status.lock = true;
		var self = this;
		var asm = this.asmUnderMouse(event);
		var blocks =  this.blocksUnderMouse(event); 
		if(blocks.length == 0 ){
			this.setBaseAssembly(this.status.assembly);
			//this.status.lock = false;
			return blocks;			
		}
		this.colorBaseAssembly(asm, true);	
		var b_new  = blocks.filter(x => !self.mouseover_blocks.includes(x));
		var b_lost = this.mouseover_blocks.filter(x => !blocks.includes(x));
		//this.status.lock = false;	
		if(b_new.length + b_lost.length > 0) {
			this.mouseover_blocks = blocks;
			this.highlightBlocks(this.mouseover_blocks);	
		}
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
					to_highlight = 	self.svg_main_rects
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
		this.svg_main_rects.selectAll(".block_bar")
		.style("fill", d => this.color(d.color_id));
	}

	clearHighlight(){
		this.current_asm = "";
		this.status.highlighted_blocks.length = 0;
		this.highlightBlocks(this.status.highlighted_blocks);
	}

	refresh_range(duration){
		var self = this;
	    this.update(duration);
	}

	colorBaseAssembly(assembly){
		this._blocks.setBaseAssembly(assembly);
		this.colorPlot();
	}

	setBaseAssembly(assembly){
		var asm_blocks = this._blocks.setBaseAssembly(assembly);
		this.colorPlot();
		this.highlightBlocks(asm_blocks);
		this.status.highlighted_blocks = asm_blocks;
	}

	mouseOutHighlight(){
		if(this.status.stop_interactions){
			return;
		}
		this.mouseover_blocks.length = 0
		this.setBaseAssembly(this.status.assembly);
		this.updateDisplayFeedback(null,0)
	}

	blocksUnderMouse = function(event){
    	var elem = document.elementsFromPoint(event.clientX, event.clientY);
   		var blocks = elem.map(e =>  e.getAttribute("block-no")).filter(a => a);
   		blocks = blocks.map(e=>parseFloat(e));
   		return blocks; 
	}

	asmUnderMouse = function(event){
   		var y_rel = event.offsetY - this.status.margin.top;
		var eachBand = this.y.step();
		var index = Math.round(((y_rel + 0.5* eachBand )/ eachBand)) - 1;
		var val = this.y.domain()[index];
		return val
	}
}

window.HaplotypeRegionPlot = HaplotypeRegionPlot;