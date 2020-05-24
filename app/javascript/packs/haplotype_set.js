import  * as d3 from 'd3'
import $ from "jquery";
import jquery from "jquery";
import "./haplotype_region";
import "./haplotype_region_set";
import "./haplotype_region_plot";
import "./haplotype_region_axis";
import "./haplotype_drag_axis";
import "./haplotype_table";
import "./current_status";

class  HaplotypePlot{
	constructor(options) {
		this.current_asm = "";
		this.tmp_asm     = "";
		this.datasets    = {};
		this.idleTimeout = null; 
		var self = this;

		this.current_status = new CurrentStatus(this);

		try{
			this.setDefaultOptions();    
	    	jquery.extend(this.opt, options);
	    	this.datasets = this.opt["datasets"];
	    	this.current_dataset = this.opt["current_dataset"]
	    	this._setUserDefaultValues();
	    	this.setupDivs();
	    	this.setupRanges();
	    	this.setupSVG();
	    	this.setupSVGInteractions();
	    	this.updateMargins();
	    	this.readData();
	  	} catch(err){
	    	alert('An error has occured');
	    	console.error(err);
	  	}
  	}  

  	get loaded(){
  		return this.current_status.loaded;
  	}

  	set loaded(val){
  		this.current_status.loaded = val;
  	}


  	setDefaultOptions (){
		this.opt = {
			'target': 'haplotype_plot', 
			'width': 800, 
			'height':500
		}
	}

	_setUserDefaultValues(){
		this.chartSVGid = this.opt.target + "_SVG";
		this.controlsDIVid = this.opt.target + "_controls"
	}

	setupDivs(){
		this.main_div = d3.select("#" + this.opt.target);
		this.controls_div = this.main_div.append("div");
		this.renderSelectDataset();
		this.renderClearSelectionBotton();
		this.main_div.append("br");
		this.svg_div = this.main_div.append("div");
		this.svg_div.attr("id", this.chartSVGid);
		this.main_div.append("br");
		this.table_div = this.main_div.append("div");
		this.hap_table = new HaplotypeTable(this.current_status);
		this.hap_table.renderTable(this.table_div)
	}

	async readData(){
		this.loaded = false;
		this.updateStatus("Loading...", true);
		this.updateMargins();
		await this.datasets[this.current_dataset].readData();
		await this.renderPlot();
		this.swapDataset(this.current_dataset);
	}

	get haplotype_region_set(){
		return this.datasets[this.current_dataset];
	}

	async swapDataset(dataset){
		var self = this;
		this.lock = false;
		this.updateMargins()
		this.updateStatus("Loading...", true);
		await self.datasets[dataset].readData();
		this.current_dataset = dataset;	
		this.haplotype_region_plot.blocks = this.datasets[this.current_dataset];	
		this.lock = true;
		this.updateMargins();	
		this.updateStatus("", false);
	}

	renderSelectDataset(){
		var self = this;
		this.datasetSelector = this.controls_div.append("select");
		for (let key of Object.keys(this.datasets)) { 
    		var ds = this.datasets[key];
    		var tmp_opt = this.datasetSelector.append("option")
    		.attr("value", ds.name)
    		.text(ds.description)
    		if(key == this.opt.current_dataset){
    			tmp_opt.attr("selected", "selected");
    		}
		}

		this.datasetSelector.on('change', function() {
    		var newData = d3.select(this).property('value');
    		self.swapDataset(newData);
		});
	}

	renderClearSelectionBotton(){
		var self = this;
		/*this.clearSelection = this.controls_div.append("botton");
		this.clearSelection.text("clear");
		this.clearSelection.on('click', function(){
			self.haplotype_region_plot.clearHighlight();
		});	*/
	}

	setupRanges(){
		this.margin = {top: 50, right: 20, bottom: 10, left: 100};
		var width = this.opt.width - this.margin.left - this.margin.right;
		var height = this.opt.height - this.margin.top - this.margin.bottom;
		this.plot_width = width;
		this.plot_height = height;
		this.y = d3.scaleBand()
		.padding(0.1);
		this.x = d3.scaleLinear()
		this.x_top = d3.scaleLinear()
		.rangeRound([0, width]);
	}

	click(event){
		this.genomes_axis.click();
		this.haplotype_region_plot.click(event);
		
		var blocks = this.current_status.blocks_for_table;
		blocks = this.haplotype_region_set.filter_blocks(blocks);
		this.hap_table.showBlocks(blocks);

	}

	mouseover(event){
		if(! this.genomes_axis){
			return;
		}
		this.haplotype_region_plot.mouseover(event);
		this.genomes_axis.mouseover(event);
	}

	setupSVGInteractions(){
		this.svg_out.on("click", () => this.click(d3.event));
		this.svg_out.on("mousemove", () => this.mouseover(d3.event));
	}

	set lock(val){
		this.current_status.lock = val;
		if(!val){
			this.update_rect
			.attr("width", 0)
			.attr("height", 0);	
		}else{
			this.update_rect
			.attr("width", this.opt.width)
			.attr("height", this.opt.height);
		}
	}

	get lock(){
		return this.current_status.lock;
	}
	
	updateMargins(){
		this.svg_out
		.attr("width", this.opt.width)
		.attr("height", this.opt.height);

		
		this.lock = this.loaded;
		this.clip_rect
		.attr("width", this.plot_width )
	    .attr("height",this.plot_height );

	    this.y.rangeRound([0, this.plot_height])
	    this.x.rangeRound([0, this.plot_width]); 
	    this.x_top.rangeRound([0, this.plot_width]); 

	}

	updateStatus(status, disableInteractions){
		this.update_label.text(status);
		this.lock = disableInteractions;
	}

	setupSVG(){    

		var self = this;		
		this.color = d3.scaleOrdinal(['#1b9e77','#d95f02','#7570b3','#e7298a','#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#a65628','#999999']);		
		this.svg_out = d3.select("#" + this.chartSVGid ).append("svg")
		.attr("id", "d3-plot");



		this.defs = this.svg_out.append("defs")
		this.clip_path = this.defs.append("svg:clipPath").attr("id", "clip");
	    this.clip_rect = this.clip_path.append("svg:rect")
	      .attr("x", 0)
	      .attr("y", 0);
	      this.svg_plot_elements = this.svg_out.append("g")
	      .attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")")
	      .attr("clip-path", "url(#clip)")
	      .attr("cursor","pointer");
	    this.haplotype_region_plot = new HaplotypeRegionPlot(this.svg_plot_elements, this.x, this.y, this.color, this.current_status);
	    
	    this.xAxis_g = this.svg_out.append("g");
	    this.xAxis_g_top = this.svg_out.append("g");
	    this.yAxis_g = this.svg_out.append("g");

	    this.update_rect = this.svg_out.append("rect").attr("class", "status_rect")
		//.attr("x", this.margin.left)
		//.attr("y", this.margin.top);
		this.update_label = this.svg_out.append("text");
		this.update_label.attr("class", "status_text");
		this.update_label.text("Rendering...");
		console.log(this.update_rect);
	}

	renderPlot(){
		var self = this;
		const data = this.datasets[this.current_dataset].data;
		const chr  = this.datasets[this.current_dataset].chromosomes_lengths;
		var assemblies = data.map(d => d.assembly);
		assemblies = [...new Set(assemblies)] ;
		var blocks     = data.map(d => d.block_no);
		blocks = [...new Set(blocks)] ;
		var max_val = d3.max(chr,d => d.length);
		this.current_status.max_val = max_val;
		this.current_status.end = max_val;
		this.x.domain([0, max_val]);
		this.x_top.domain([0, max_val]);
	  	this.y.domain(assemblies);
		this.color.domain(assemblies);
		
		this.main_region_axis = new RegionAxis(this.xAxis_g, this.x, this,  this.current_status);
		this.main_region_axis.translate(this.margin.left, this.margin.top);
		this.main_region_axis.enable_zoom_brush(max_val, this);
		
		this.top_region_axis = new DragAxis(this.xAxis_g_top, this.x_top, this, this.current_status);
		this.top_region_axis.translate(this.margin.left, this.margin.top/3);
	  	
		this.genomes_axis = new GenomesAxis(this.yAxis_g, this.y, this.current_status);
		this.genomes_axis.translate(this.margin.left, this.margin.top)
		this.genomes_axis.enable_click(this);
	}

	setBaseAssembly(assembly){
		this.haplotype_region_plot.setBaseAssembly(assembly);
		//this.current_status.assembly = assembly;
	}

	clearHighlight(){
		this.haplotype_region_plot.clearHighlight();
	}

	setRange(range){
		var duration = 500;
		var min_range = this.haplotype_region_plot.blocks.shortest_block_length * 2;
		var range_length = range[1] - range[0] ;

		if(range_length < min_range){
			range[0] -= min_range;
			range[1] += min_range
		}

		if( range[1] > this.current_status.max_val){
			 range[1] = this.current_status.max_val;
		}
		if(range[0] < 0){
			range[0] = 0;
		}

		this.current_status.start = range[0];
		this.current_status.end   = range[1];
		
		this.haplotype_region_plot.blocks.region = range;

		this.x.domain(range);

   		this.haplotype_region_plot.refresh_range(duration);
   		this.main_region_axis.refresh_range(duration);
   		this.top_region_axis.refresh_range(duration);
	}

}


window.HaplotypePlot = HaplotypePlot;
