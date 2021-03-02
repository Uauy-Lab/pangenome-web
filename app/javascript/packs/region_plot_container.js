class RegionPlotContainer extends PlotContainer{
	constructor(svg_g, width, height, current_status, margin){
		super(svg_g, width, height, 0, 0, current_status)
		
		this.defs = this.g.append("defs")
		this.clip_path = this.defs.append("svg:clipPath").attr("id", "clip");
	    this.clip_rect = this.clip_path.append("svg:rect")
	      .attr("x", 0)
	      .attr("y", 0);
	    this._margin = margin;

	    this.svg_plot_elements = this.g.append("g")
	      .attr("transform", "translate(" + this._margin.left + "," + this._margin.top + ")")
	      .attr("clip-path", "url(#clip)")
	      .attr("cursor","pointer");
	    
	
	  }

	set margin(m){
		this._margin = m;	
	}

	get rendered_height(){
		if(! this._virtual_plot_height){
			this._virtual_plot_height = 0;
		}
		console.log("RH: " +( this._virtual_plot_height + this._margin.top + this._margin.bottom));
		return this._virtual_plot_height + this._margin.top + this._margin.bottom;
	}


	update(){
		var width  = this._width - this._margin.left - this._margin.right;
		var height = this._height - this._margin.top - this._margin.bottom;
		// console.log(this._width);
		// console.log(this._height);
		console.log(this._margin);
		// console.log(width);
		// console.log(height);

		this.plot_width = width;
		this.plot_height = height;
		this.clip_rect
		.attr("width", this.plot_width )
	    .attr("height",this.plot_height );

	    var da = this._current_status.displayed_assemblies;
	    var virtual_plot_height = height;

	    if(da){
	    	var total = 0;
	    	var vals = da.values();
	    	for(const d of vals){
	    		if(d) total++;
	    	}
	    	this._virtual_plot_height = (total / da.size) * this.plot_height ;
	    }
	    this._y.rangeRound([0, this._virtual_plot_height])
	    this._x.rangeRound([0, this.plot_width]); 
	    this.x_top.rangeRound([0, this.plot_width]); 
	    this._margin.rendered_height = this.rendered_height;

	}

	renderPlot(){
		var self = this;
		this.haplotype_region_plot = new HaplotypeRegionPlot(this.svg_plot_elements, this._x, this._y, this._current_status.color, this._current_status);
	    
	    this.xAxis_g = this.g.append("g");
	    this.xAxis_g_top = this.g.append("g");
	    this.yAxis_g = this.g.append("g");
	    console.log("We are going to render!");
	    console.log(this.g);
	    
		
		this.assembly_region_plot = new AssemblyRegionPlot(this.svg_plot_elements, this._x, this._y, this._current_status);

		const data = this._current_status.datasets[this._current_status.current_dataset].data;
		const chr  = this._current_status.datasets[this._current_status.current_dataset].chromosomes_lengths;
		var assemblies = data.map(d => d.assembly);
		assemblies = [...new Set(assemblies)] ;
		var blocks     = data.map(d => d.block_no);
		blocks = [...new Set(blocks)] ;
		var max_val = d3.max(chr,d => d.length);
		this._current_status.max_val = max_val;
		this._current_status.end = max_val;
		this._x.domain([0, max_val]);
		this.x_top.domain([0, max_val]);
		this.updateAssembliesDomain();
		this.main_region_axis = new RegionAxis(this.xAxis_g, this._x, this,  this._current_status);
		this.main_region_axis.translate(this._margin.left, this._margin.top);
		this.main_region_axis.enable_zoom_brush(max_val, this);
		
		this.top_region_axis = new DragAxis(this.xAxis_g_top, this.x_top, this, this._current_status);
		this.top_region_axis.translate(this._margin.left, this._margin.top/3);
	  	
		this.genomes_axis = new GenomesAxis(this.yAxis_g, this._y, this._current_status);
		this.genomes_axis.translate(this._margin.left, this._margin.top)
		this.genomes_axis.enable_click(this);
	}

	updateAssembliesDomain(){
		var self = this;
		const data = this._current_status.datasets[this._current_status.current_dataset];
		var asms = data.assemblies;
		if(this._current_status.displayed_assemblies == undefined){
			this._current_status.displayed_assemblies = asms;
		}
		const displayed = this._current_status.displayed_assemblies;
		this.rendered_assemblies = [];
		// console.log(displayed);
		displayed.forEach((k,v)=>{
			if(k) self.rendered_assemblies.push(v);
		});
		//this.rendered_assemblies = asms.filter(asm => displayed[asm] );
		this._y.domain(this.rendered_assemblies);
		this._current_status.color.domain(this.rendered_assemblies);
	}

	refresh_range(duration){
		this.haplotype_region_plot.refresh_range(duration);
   		this.assembly_region_plot.updatePositionLine(duration);
   		this.assembly_region_plot.updateCoords(duration);
   		this.main_region_axis.refresh_range(duration);
   		this.top_region_axis.refresh_range(duration);
	}

	set region(range){
		this.haplotype_region_plot.blocks.region = range;
	}

}

window.RegionPlotContainer = RegionPlotContainer;