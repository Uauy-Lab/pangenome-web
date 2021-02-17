import  * as d3 from 'd3'
import $ from "jquery";
import jquery from "jquery";
import "./region";
import "./haplotype_region";
import "./haplotype_region_set";
import "./haplotype_region_plot";
import "./haplotype_region_axis";
import "./haplotype_drag_axis";
import "./haplotype_table";
import "./current_status";
import "./assembly_region_plot";
import "./assembly_region_set";

class  HaplotypePlot{
	constructor(options) {
		this.current_asm = "";
		this.tmp_asm     = "";
		this.datasets    = {};
		this.idleTimeout = null; 
		this.coord_mapping = {};
		this.current_coord_mapping = null;
		var self = this;
		this.current_status = new CurrentStatus(this);
		this.setDefaultOptions();    
		jquery.extend(this.opt, options);
		this.datasets = this.opt["datasets"];
		this.current_dataset = this.opt["current_dataset"];
		this.coord_mapping = this.opt["coord_mapping"];
		this.current_status.current_coord_mapping = this.opt["current_coord_mapping"];
		this.current_status.displayed_assemblies = this.opt["assemblies"];
		this.opt["assemblies"].forEach(f=>{
				self.current_status.displayed_assemblies.set(f, self.opt["displayed_assemblies"].includes(f));
			}
		)
		this._setUserDefaultValues();
		this.setupDivs();
		this.setupRanges();
		this.setupSVG();
		this.setupSVGInteractions();
		this.updateMargins();
		this.readData();
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
			'height':500,
			'current_coord_mapping': '2mbp'
		}
	}

	_setUserDefaultValues(){
		this.chartSVGid = this.opt.target + "_SVG";
		this.controlsDIVid = this.opt.target + "_controls"
	}

	get width(){
  		//return this.opt.width;
  		var element = this.svg_div.node();
  		return element.getBoundingClientRect().width;
  	}


	setupDivs(){
		this.main_div = d3.select("#" + this.opt.target);
		this.main_div.classed("haplotype-wrapper", true)
		this.controls_div = this.main_div.append("div")
		this.controls_div.classed("haplotype-control", true);
		this.renderSelectDataset();
		this.svg_div = this.main_div.append("div");
		this.svg_div.attr("id", this.chartSVGid);
		this.svg_div.classed("haplotype-plot", true);
		this.table_div = this.main_div.append("div");
		this.hap_table = new HaplotypeTable(this.current_status);
		this.hap_table.renderTable(this.table_div);
		this.table_div.classed("haplotype-table", true);
		d3.select(window).on('resize', () => {this.updateMargins(); this.setRange(this.range); });
	}

	async readData(){
		this.loaded = false;
		this.updateStatus("Loading...", true);
		this.updateMargins();
		await this.datasets[this.current_dataset].readData();
		await this.renderPlot();
		this.current_status.assemblies_reference = this.datasets[this.current_dataset].assemby_reference;
		this.swapDataset(this.current_dataset);
		this.coord_mapping[this.current_status.current_coord_mapping].readData(this.current_status);
		//console.log(this.coord_mapping[this.current_coord_mapping]);
	}

	get haplotype_region_set(){
		return this.datasets[this.current_dataset];
	}

	async swapDataset(dataset){
		var self = this;
		this.updateMargins()
		this.updateStatus("Loading...", true);
		await self.datasets[dataset].readData();
		this.current_dataset = dataset;	
		this.haplotype_region_plot.blocks = this.datasets[this.current_dataset];	
		this.updateMargins();	
		this.updateOnOffLines();
		this.updateStatus("", false);
		this.hap_table.showBlocks(this.haplotype_region_plot.blocks.filter_blocks());

	}

	updateOnOffLines(){
		var self = this;
		var assemblies = this.haplotype_region_plot.blocks.chromosomes_lengths;
		var to_modify = this.scoreLabels;
		var duration = 500;
		console.log("updating swithces");
		console.log(self.current_status.displayed_assemblies);
		to_modify.attr("class","score_labels")
		.selectAll(".asm_label")
		.data(assemblies, d=>d.assembly)
		.join(
			enter => {
				var tmp_div = enter.append("div").
				attr("asm", d=>{d.assembly}).
				attr("class", "asm_label")
				var lab   = tmp_div.append("label").attr("class","switch");
				var input = lab.append("input").attr("type","checkbox")
				var span  = lab.append("span").attr("class", "slider round");
				var txt   = tmp_div.append("label").text(d=>d.assembly);
				input.property("checked", d=> self.current_status.displayed_assemblies.get(d.assembly))
				.on("change", function(d){
					var newData = d3.select(this).property('checked');
					self.current_status.displayed_assemblies.set(d.assembly, newData);
					self.updateMargins();	
					self.updateAssembliesDomain();
					self.haplotype_region_plot.updateBlocks(duration);
					self.haplotype_region_plot.updateChromosomes(duration);
					self.genomes_axis.refresh_range(duration);
				});
				}
			)
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
		this.scoreLabels = this.controls_div.append("div")
		this.scoreLabelsID = this.opt.target+"_scoreLabels";
		this.scoreLabels.attr("id", this.scoreLabelsID);

	}

	setupRanges(){
		this.margin = {top: 50, right: 20, bottom: 10, left: 100};
		var width  = this.width      - this.margin.left - this.margin.right;
		var height = this.opt.height - this.margin.top  - this.margin.bottom;
		this.plot_width  = width;
		this.plot_height = height;
		this.y = d3.scaleBand()
		.padding(0.1);
		this.x     = d3.scaleLinear()
		this.x_top = d3.scaleLinear()
		.rangeRound([0, width]);
	}

	click(event){
		var coords = this.haplotype_region_plot.event_coordinates(event);
		if(coords.in_plot && coords.x > 0 && coords.asm !== undefined ){
			this.current_status.toggle_frozen();
			if(this.current_status.frozen){
				this.current_status.selected_assembly = coords.asm;
			}else{
				this.current_status.selected_assembly = undefined;
			}
			this.haplotype_region_plot.click(coords);
		}
		if(coords.in_y_axis){
			this.genomes_axis.click(coords);	
		}
		
		var blocks = this.current_status.blocks_for_table;
		blocks = this.haplotype_region_set.filter_blocks(blocks);
		this.hap_table.showBlocks(blocks);

	}	

	mouseover(event){
		if(! this.genomes_axis || 
			this.current_status.stop_interactions){
			return;
		}
		
		var coords = this.haplotype_region_plot.event_coordinates(event);

		//console.log(coords);
		if(coords.in_plot){
			this.current_status.display_coords = coords;
			this.haplotype_region_plot.mouseover(coords);
			this.assembly_region_plot.mouseover(coords);
		}


		if(coords.in_y_axis){
			this.genomes_axis.mouseover(coords);
		}
		
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
			.attr("width", this.width)
			.attr("height", this.opt.height);
		}
	}

	get lock(){
		return this.current_status.lock;
	}
	
	updateMargins(){

		var width = this.width - this.margin.left - this.margin.right;
		var height = this.opt.height - this.margin.top - this.margin.bottom;
		this.plot_width = width;
		this.plot_height = height;


		this.svg_out
		.attr("width", this.width)
		.attr("height", this.opt.height);

		this.clip_rect
		.attr("width", this.plot_width )
	    .attr("height",this.plot_height );
	    var da = this.current_status.displayed_assemblies;
	    var virtual_plot_height = height;
	    if(da){
	    	var total = 0;
	    	var vals = da.values();
	    	for(const d of vals){
	    		if(d) total++;
	    	}	
	    	virtual_plot_height = (total / da.size) * this.plot_height ;
	    	
	    }
	    
	   
	    this.y.rangeRound([0, virtual_plot_height])
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

		this.assembly_region_plot = new AssemblyRegionPlot(this.svg_plot_elements, this.x, this.y, this.current_status);
		//console.log(this.update_rect);
	}

	updateAssembliesDomain(){
		var self = this;
		const data = this.datasets[this.current_dataset];
		var asms = data.assemblies;
		if(this.current_status.displayed_assemblies == undefined){
			this.current_status.displayed_assemblies = asms;
		}
		const displayed = this.current_status.displayed_assemblies;
		this.rendered_assemblies = [];
		console.log(displayed);
		displayed.forEach((k,v)=>{
			console.log(self.rendered_assemblies);
			console.log(v);
			console.log(k);
			if(k) self.rendered_assemblies.push(v);
		});
		//this.rendered_assemblies = asms.filter(asm => displayed[asm] );
		this.y.domain(this.rendered_assemblies);
		this.color.domain(this.rendered_assemblies);
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
		this.updateAssembliesDomain();
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
		this.current_status.selected_blocks = this.haplotype_region_plot.setBaseAssembly(assembly);
		this.current_status.assembly = assembly;
		this.highlightBlocks(this.current_status.selected_blocks);
		return this.current_status.selected_blocks ;
	}

	highlightBlocks(blocks){
		this.haplotype_region_plot.highlightBlocks(blocks);
	}
	clearHighlight(){
		this.haplotype_region_plot.clearHighlight();
	}

	get range(){
		return [this.current_status.start, this.current_status.end]
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
   		this.assembly_region_plot.updatePositionLine(duration);
   		this.assembly_region_plot.updateCoords(duration);
   		this.main_region_axis.refresh_range(duration);
   		this.top_region_axis.refresh_range(duration);
   		this.hap_table.displayZoomed();
	}

}


window.HaplotypePlot = HaplotypePlot;
