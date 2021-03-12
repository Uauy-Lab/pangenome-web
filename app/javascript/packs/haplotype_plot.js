import  * as d3 from 'd3'
//import $ from "jquery";
import jquery from "jquery";
import "./plot_container"
import "./axis"
import "./region_axis"
import "./genomes_axis"
import "./region_axis";
import "./region_score_axis";
import "./region";
import "./haplotype_region";
import "./haplotype_region_set";
import "./haplotype_region_plot";
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
			var val = true;
			if(self.opt["displayed_assemblies"]){
				val = self.opt["displayed_assemblies"].includes(f);
			}
			self.current_status.displayed_assemblies.set(f, val);

			}
		)
		// console.log("options");
		// console.log(options);
		this._region_scores = this.opt['region_scores_container'];
		this.current_status.display_samples = this.opt['display_samples'];
		this.current_status.display_score   = this.opt['display_score'];
		this.current_status.toggle_assemblies = this.opt['toggle_assemblies'];
		//this._region_scores.display_sample("flame_kmerGWAS", true);
		//this._region_scores.hap_plot.display_score = "total_kmers";
		this.current_status.height = this.opt['height'];

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
			'current_coord_mapping': '2mbp',
			'toggle_assemblies': false,
			'assemblies': null,
			'display_samples': false,
			'display_score': null,
			displayed_assemblies: false
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
			for (const l of this.current_status.display_samples) {
				for(const k of this.current_status.displayed_assemblies.keys()){
					var v = this.current_status.displayed_assemblies.get(k);
					this.display_sample(l, k, v)	

				}
			}

			// this.current_status.display_samples.forEach(l =>
			// 	this.current_status.displayed_assemblies.forEach((v,k) =>
			// 		await 
			// 	)
			// )
			//this.region_score_plot_container.refresh_range(500);
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
		this.prepareScorePlots();
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
		console.log("About to render toggles");
		console.log(this.current_status);
		if(this.current_status.toggle_assemblies == false){
			console.log("We are not suppsoed to render the checkboxes!");
			return;

		}
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
					console.log("Adding to displayed_samples" + d.assembly);
					self.current_status.displayed_assemblies.set(d.assembly, newData);
					self.current_status.displayed_samples.add(d.assembly);
					self.updateMargins();	
					self.region_plot_container.updateAssembliesDomain();
					self.region_plot_container.haplotype_region_plot.updateBlocks(duration);
					self.region_plot_container.haplotype_region_plot.updateChromosomes(duration);
					self.region_plot_container.genomes_axis.refresh_range(duration);
					self.prepareScorePlots();
					console.log(self.current_status.displayed_samples);
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
		this.margin = {top: 50, right: 20, bottom: 10, left: 150, virtual_plot_height:100};
		var width  = this.width      - this.margin.left - this.margin.right;
		var height = this.opt["height"] - this.margin.top  - this.margin.bottom;
		this.current_status.plot_height = height;
		this.plot_width  = width;
		this.plot_height = height;
		this.y = d3.scaleBand()
		.padding(0.1);
		this.x     = d3.scaleLinear();
		this.x_top = d3.scaleLinear()
		.rangeRound([0, width]);
		this.y_scores      = d3.scaleLinear().rangeRound([0,this.plot_height]);
		this.y_scores_full = d3.scaleLinear().rangeRound([0,this.plot_height]);
		
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
		// 	.attr("height", this.current_status.plot_height);
		// }
	}

	get lock(){
		return this.current_status.lock;
	}
	
	updateMargins(){
		this.svg_out
		.attr("width", this.width)
		.attr("height", this.current_status.plot_height);
	    this.region_plot_container.width = this.width;
	    this.region_plot_container.height = this.current_status.plot_height;
	 	this.region_plot_container.update();   
	 	this.region_score_plot_container.update()

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

		this.region_plot_container = new RegionPlotContainer(this.svg_out, this.width, this.current_status.plot_height, this.current_status, this.margin);
		this.region_plot_container.x = this.x;
		this.region_plot_container.y = this.y;
		this.region_plot_container.x_top = this.x_top;
		this.region_plot_container.margin = this.margin

		this.update_label = this.svg_out.append("text");
		this.update_label.attr("class", "status_text");
		this.update_label.text("Rendering...");

		this.region_score_plot_container = new RegionScorePlotContainer(
			this.svg_out,
			this.width, 
			this.current_status.plot_height, 
			0,
			this.region_plot_container.rendered_height, 
			this.current_status, 
			this.margin)
;
	}

	renderPlot(){

		this.region_plot_container.renderPlot();	
		this.region_score_plot_container.renderPlot();
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
   		this.region_score_plot_container.refresh_range(duration);
	}

	setScoreRange(range){
		var duration = 500;
		this.y_scores.domain(range);
		this.region_score_plot_container.refresh_range(duration);
		console.log(range);
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

	async display_sample(sample, reference, enabled){
		
		//var reference = "arinalrfor";
		var id = sample + "-" + reference;
		
		if(enabled){
			var tmp = await this._region_scores.sample(sample, reference);
			console.log("Enabling " + sample + "..." + reference);
			console.log(this._region_scores);
			this.region_score_plot_container.addPlot(id, tmp);
			this.current_status.displayed_samples.add(sample);
		}else{
			// console.log("Disabling " + sample + "..." + reference);
			// console.log(this._region_scores);
			this.region_score_plot_container.removePlot(id);
			this.current_status.displayed_samples.delete(sample);
		}
		

	}
}


window.HaplotypePlot = HaplotypePlot;
