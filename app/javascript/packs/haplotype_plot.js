import  * as d3 from 'd3'
//import $ from "jquery";
import jquery from "jquery";
import "./plot_container"
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
import "./region_score_container";
import "./region_score";
import "./region_score_set";
import "./region_score_plot_container"
import "./region_score_plot"

import "./region_plot_container"

class  HaplotypePlot{
	constructor(options) {
		this.current_asm = "";
		this.tmp_asm     = "";
		this.idleTimeout = null; 
		this.coord_mapping = {};
		this.current_coord_mapping = null;
		var self = this;
		this.current_status = new CurrentStatus(this);
		this.setDefaultOptions();    
		jquery.extend(this.opt, options);
		this.current_status.datasets = this.opt["datasets"];
		this.current_status.current_dataset = this.opt["current_dataset"];
		this.coord_mapping = this.opt["coord_mapping"];
		this.current_status.current_coord_mapping = this.opt["current_coord_mapping"];
		this.current_status.displayed_assemblies = this.opt["assemblies"];
		this.opt["assemblies"].forEach(f=>{
				self.current_status.displayed_assemblies.set(f, self.opt["displayed_assemblies"].includes(f));
			}
		)
		console.log("options");
		console.log(options);
		this._region_scores = options['region_scores_container'];
		this.current_status.display_samples = options['display_samples'];
		this.current_status.display_score   = options['display_score'];
		//this._region_scores.display_sample("flame_kmerGWAS", true);
		//this._region_scores.hap_plot.display_score = "total_kmers";

		this._setUserDefaultValues();
		this.setupDivs();
		this.setupRanges();
		this.setupSVG();
		this.setupSVGInteractions();
		this.updateMargins();
		this.prepareScorePlots();
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

	prepareScorePlots(){
		if(this.current_status.display_samples){
			this.current_status.display_samples.forEach(l =>
				this.display_sample(l , true)
				)
		}
	}

	async readData(){
		this.loaded = false;
		this.updateStatus("Loading...", true);
		this.updateMargins();
		await this.current_status.datasets[this.current_status.current_dataset].readData();
		await this.renderPlot();

		this.current_status.assemblies_reference = this.current_status.datasets[this.current_status.current_dataset].assemby_reference;
		this.swapDataset(this.current_status.current_dataset);
		this.coord_mapping[this.current_status.current_coord_mapping].readData(this.current_status);
		//console.log(this.coord_mapping[this.current_coord_mapping]);
	}

	get haplotype_region_set(){
		return this.current_status.datasets[this.current_status.current_dataset];
	}

	async swapDataset(dataset){
		var self = this;
		this.updateMargins()
		this.updateStatus("Loading...", true);
		await self.current_status.datasets[dataset].readData();
		this.current_status.current_dataset = dataset;	
		this.region_plot_container.haplotype_region_plot.blocks = this.current_status.datasets[this.current_status.current_dataset];	
		this.updateMargins();	
		this.updateOnOffLines();
		this.updateStatus("", false);
		this.hap_table.showBlocks(this.region_plot_container.haplotype_region_plot.blocks.filter_blocks());

	}

	updateOnOffLines(){
		var self = this;
		var assemblies = this.region_plot_container.haplotype_region_plot.blocks.chromosomes_lengths;
		var to_modify = this.scoreLabels;
		var duration = 500;
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
					self.region_plot_container.updateAssembliesDomain();
					self.region_plot_container.haplotype_region_plot.updateBlocks(duration);
					self.region_plot_container.haplotype_region_plot.updateChromosomes(duration);
					self.region_plot_container.genomes_axis.refresh_range(duration);
				});
				}
			)
	}

	renderSelectDataset(){
		var self = this;
		this.current_status.datasetSelector = this.controls_div.append("select");
		for (let key of Object.keys(this.current_status.datasets)) { 
    		var ds = this.current_status.datasets[key];
    		var tmp_opt = this.current_status.datasetSelector.append("option")
    		.attr("value", ds.name)
    		.text(ds.description)
    		if(key == this.opt.current_dataset){
    			tmp_opt.attr("selected", "selected");
    		}
		}

		this.current_status.datasetSelector.on('change', function() {
    		var newData = d3.select(this).property('value');
    		self.swapDataset(newData);
		});
		this.scoreLabels = this.controls_div.append("div")
		this.scoreLabelsID = this.opt.target+"_scoreLabels";
		this.scoreLabels.attr("id", this.scoreLabelsID);

	}

	setupRanges(){
		this.margin = {top: 50, right: 20, bottom: 10, left: 100, virtual_plot_height:100};
		var width  = this.width      - this.margin.left - this.margin.right;
		var height = this.opt.height - this.margin.top  - this.margin.bottom;
		this.plot_width  = width;
		this.plot_height = height;
		this.y = d3.scaleBand()
		.padding(0.1);
		this.x     = d3.scaleLinear();
		this.x_top = d3.scaleLinear()
		.rangeRound([0, width]);
		this.y_scores = d3.scaleLinear().rangeRound([0,this.plot_height]);
		
	}

	click(event){
		var coords = this.region_plot_container.haplotype_region_plot.event_coordinates(event);
		if(coords.in_plot && coords.x > 0 && coords.asm !== undefined ){
			this.current_status.toggle_frozen();
			if(this.current_status.frozen){
				this.current_status.selected_assembly = coords.asm;
			}else{
				this.current_status.selected_assembly = undefined;
			}
			this.region_plot_container.haplotype_region_plot.click(coords);
		}
		if(coords.in_y_axis){
			this.region_plot_container.genomes_axis.click(coords);	
		}
		
		var blocks = this.current_status.blocks_for_table;
		blocks = this.haplotype_region_set.filter_blocks(blocks);
		this.hap_table.showBlocks(blocks);

	}	

	mouseover(event){

		if(! this.region_plot_container.genomes_axis || 
			this.current_status.stop_interactions){
			return;
		}
		
		var coords = this.region_plot_container.haplotype_region_plot.event_coordinates(event);

		//console.log(coords);
		if(coords.in_plot){
			this.current_status.display_coords = coords;
			this.region_plot_container.haplotype_region_plot.mouseover(coords);
			this.region_plot_container.assembly_region_plot.mouseover(coords);
		}


		if(coords.in_y_axis){
			this.region_plot_container.genomes_axis.mouseover(coords);
		}
		
	}

	setupSVGInteractions(){
		this.svg_out.on("click", () => this.click(d3.event));
		this.svg_out.on("mousemove", () => this.mouseover(d3.event));
	}

	set lock(val){
		this.current_status.lock = val;
		//TODO: Bring this back. This was not working very way anyway...
		// if(!val){
		// 	this.update_rect
		// 	.attr("width", 0)
		// 	.attr("height", 0);	
		// }else{
		// 	this.update_rect
		// 	.attr("width", this.width)
		// 	.attr("height", this.opt.height);
		// }
	}

	get lock(){
		return this.current_status.lock;
	}
	
	updateMargins(){
		this.svg_out
		.attr("width", this.width)
		.attr("height", this.opt.height);
	    this.region_plot_container.width = this.width;
	    this.region_plot_container.height = this.opt.height;
	 	this.region_plot_container.update();   
	 	this.region_scores_container.update()

	}

	updateStatus(status, disableInteractions){
		this.update_label.text(status);
		this.lock = disableInteractions;
	}

	setupSVG(){    

		var self = this;		
		this.current_status.color = d3.scaleOrdinal(['#1b9e77','#d95f02','#7570b3','#e7298a','#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#a65628','#999999']);		
		this.svg_out = d3.select("#" + this.chartSVGid ).append("svg")
		.attr("id", "d3-plot");

		this.region_plot_container = new RegionPlotContainer(this.svg_out, this.width, this.opt.height, this.current_status, this.margin);
		this.region_plot_container.x = this.x;
		this.region_plot_container.y = this.y;
		this.region_plot_container.x_top = this.x_top;
		this.region_plot_container.margin = this.margin

		this.update_label = this.svg_out.append("text");
		this.update_label.attr("class", "status_text");
		this.update_label.text("Rendering...");

		this.region_scores_container = new RegionScorePlotContainer(
			this.svg_out,
			this.width, 
			this.opt.height, 
			0,
			this.region_plot_container.rendered_height, 
			this.current_status, 
			this.margin)
;
	}

	renderPlot(){

		this.region_plot_container.renderPlot();	
		this.region_scores_container.renderPlot();
	}

	setBaseAssembly(assembly){
		this.current_status.selected_blocks = this.region_plot_container.haplotype_region_plot.setBaseAssembly(assembly);
		this.current_status.assembly = assembly;
		this.highlightBlocks(this.current_status.selected_blocks);
		return this.current_status.selected_blocks ;
	}

	highlightBlocks(blocks){
		this.region_plot_container.haplotype_region_plot.highlightBlocks(blocks);
	}
	clearHighlight(){
		this.region_plot_container.haplotype_region_plot.clearHighlight();
	}

	get range(){
		return [this.current_status.start, this.current_status.end]
	}

	setRange(range){
		var duration = 500;
		var min_range = this.region_plot_container.haplotype_region_plot.blocks.shortest_block_length * 2;
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
		
		this.region_plot_container.region = range ; //TODO: move the code inside to a set of the exposed blocks at this level
		this.x.domain(range);
		this.region_plot_container.refresh_range(duration);

   		
   		this.hap_table.displayZoomed();
   		this.region_scores_container.refresh_range(duration);
	}

	set region_scores(rs){
		this._region_scores = rs;
	}

	// set display_score(score){
	// 	if(!this._region_scores){
	// 		console.warn("_region_scores is not defined");
	// 		return;
	// 	}
	// 	this._region_scores.score = score;
	// 	this._region_score_domain_changed = true;

	// 	// console.log("display_score");
	// 	// console.log(this._region_scores.range);
	// 	// this.y_scores.domain(this._region_scores.range);

	// }

	async display_sample(sample, enabled){
		console.log(this._region_scores);
		var tmp = await this._region_scores.sample(sample);
		this.current_status.displayed_samples.push(sample);
		console.log("display_sample");
		console.log(tmp);

		this.region_scores_container.addPlot(tmp.name, tmp);
		this.region_scores_container.refresh_range(500);

	}
}


window.HaplotypePlot = HaplotypePlot;
