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
import "./table";
import "./haplotype_region";
import "./haplotype_region_set";
import "./haplotype_region_plot";
import "./haplotype_drag_axis";
import "./haplotype_table";
import "./event_coordinates";
import "./current_status";
import "./assembly_region_plot";
import "./assembly_region_set";
import "./region_score_container";
import "./region_score";
import "./region_score_set";
import "./region_score_plot_container";
import "./region_score_plot";
import "./search_box";
import "./region_feature";
import "./region_plot_container";
import "./feature_table";
import "./mapping_coordinates_plot";
import "./mapping_coordinates_region";
import "./mapping_coordinates_region_set";


class  HaplotypePlot{
	constructor(options) {
		this.current_asm = "";
		this.tmp_asm     = "";
		this.idleTimeout = null; 
		this.coord_mapping = {};
		this.current_coord_mapping = null;
		this.current_status = new CurrentStatus(this);
		this.setDefaultOptions();    
		jquery.extend(this.opt, options);
		this.current_status.app_status = this.opt['app_status'];
		this.current_status.datasets   = this.opt["datasets"];
		this.current_status.current_dataset = this.opt["current_dataset"];
		this.coord_mapping = this.opt["coord_mapping"];
		this.current_status.current_coord_mapping = this.opt["current_coord_mapping"];
		this.current_status.displayed_assemblies  = this.opt["assemblies"];
		this.opt["assemblies"].forEach(f=>{
			var val = true;
			if(this.opt["displayed_assemblies"]){
				val = this.opt["displayed_assemblies"].includes(f);
			}
			this.current_status.displayed_assemblies.set(f, val);
		});
		this._region_scores                   = this.opt['region_scores_container'];
		this.current_status.display_samples   = this.opt['display_samples'];
		this.current_status.display_score     = this.opt['display_score'];
		this.current_status.toggle_assemblies = this.opt['toggle_assemblies'];
		//this._region_scores.display_sample("flame_kmerGWAS", true);
		//this._region_scores.hap_plot.display_score = "total_kmers";
		this.current_status.height = this.opt['height'];
		this.current_status.region_feature_set = new RegionFeatureSet(this.opt.autocomplete, this.current_status);

		this._setUserDefaultValues();
		this.setupDivs();
		this.setupRanges();
		this.setupSVG();
		this.setupSVGInteractions();
		this.updateMargins();		
		this.readData();
		this.opt["features"].forEach( g => {
			this.current_status.add_feature(g);
		})
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
			'displayed_assemblies': false, 
			'display_haplotype_table' : true,
			'display_feature_table' : true,
			'autocomplete' : false, 
			'features' : [],
			'app_status': null
		}
	}

	_setUserDefaultValues(){
		this.chartSVGid = this.opt.target + "_SVG";
		this.controlsDIVid = this.opt.target + "_controls"
	}

	get width(){
  		var element = this.svg_div.node();
  		return element.getBoundingClientRect().width;
  	}

	get height(){
		var element = this.svg_div.node();
		return element.getBoundingClientRect().height;
	}

	setupDivs(){
		this.main_div = d3.select("#" + this.opt.target);
		this.main_div.classed("haplotype-wrapper", true)
		this.controls_div = this.main_div.append("div")
		this.controls_div.classed("haplotype-control", true);
		
		this.search_box = new SearchBox(this.controls_div, this.opt.autocomplete, this.current_status, this.opt.target);

		this.renderSelectDataset();
		this.svg_div = this.main_div.append("div");
		this.svg_div.attr("id", this.chartSVGid);
		this.svg_div.classed("haplotype-plot", true);
		
		this.tables_div = this.main_div.append("div");
		this.tables_div.classed("table-container", true);

		if(this.opt.display_haplotype_table){
			this.table_hap_div = this.tables_div.append("div");
			this.hap_table     = new HaplotypeTable(this.current_status);
			this.hap_table.renderTable(this.table_hap_div);
			this.table_hap_div.classed("haplotype-table", true);
		}

		if(this.opt.display_feature_table){
			this.table_feat_div = this.tables_div.append("div");
			this.feat_table     = new FeatureTable(this.current_status);
			this.feat_table.renderTable(this.table_feat_div);
			this.table_feat_div.classed("haplotype-table", true);
		}
		
		d3.select(window).on('resize', () => {
			this.updateMargins(); 
			this.setRange(this.range); 
		});
	}

	prepareScorePlots(){
		if(this.current_status.display_samples){
			for (const l of this.current_status.display_samples) {
				for(const k of this.current_status.displayed_assemblies.keys()){
					var v = this.current_status.displayed_assemblies.get(k);
					this.display_sample(l, k, v);
				}
			}
		}
	}

	async readData(){
		this.loaded = false;
		this.updateStatus("Loading...", true);
		this.updateMargins();
		console.log(this.current_status);
		await this.current_status.haplotype_region_set.readData();
		this.renderPlot();
		this.current_status.assemblies_reference = this.current_status.haplotype_region_set.assemby_reference;
		this.swapDataset(this.current_status.current_dataset);
		this.coord_mapping[this.current_status.current_coord_mapping].readData(this.current_status);
		this.prepareScorePlots();
	}

	get haplotype_region_set(){
		return this.current_status.haplotype_region_set;
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

		if(this.hap_table){
			this.hap_table.showBlocks(
				this.region_plot_container.haplotype_region_plot.blocks.filter()
			);
		}

	}

	updateOnOffLines(){
		if(this.current_status.toggle_assemblies == false){
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
					self.current_status.displayed_assemblies.set(d.assembly, newData);
					self.current_status.displayed_samples.add(d.assembly);
					self.updateMargins();	
					self.region_plot_container.updateAssembliesDomain();
					self.region_plot_container.haplotype_region_plot.updateBlocks(duration);
					self.region_plot_container.haplotype_region_plot.updateChromosomes(duration);
					self.prepareScorePlots();
					self.refresh(duration);
				});
				}
			)
	}

	renderSelectDataset(){
		var self = this;
		this.current_status.datasetSelector = this.controls_div.append("select");
		this.current_status.datasetSelector.classed('hap-set-select', true);
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
			var hap_select = d3.select(this);
			var newData = hap_select.property('value');
			self.swapDataset(newData);
			d3.selectAll(".hap-set-select").each( function(d,i){
				var current_select = d3.select(this);
				if(current_select != hap_select){
					current_select.property('value', newData);
				}
			})
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
		console.log("Registered click");
		console.log(coords);
		if(coords.in_plot && coords.x > 0 && coords.asm !== undefined ){
			this.current_status.toggle_frozen();
			// if(this.current_status.frozen){
			// 	this.current_status.selected_assembly = coords.asm;
			// }else{
			// 	this.current_status.selected_assembly = undefined;
			// }
			this.region_plot_container.haplotype_region_plot.click(coords);
		}
		if(coords.in_y_axis){
			this.region_plot_container.genomes_axis.click(coords);	
		}
		// var blocks = this.current_status.blocks_for_table;
		// blocks = this.haplotype_region_set.filter(blocks);
		// if(this.hap_table){
		// 	this.hap_table.showBlocks(blocks);
		// }
		this.current_status.update_table_and_highlights();

	}	

	mouseover(event){
		if(! this.region_plot_container.genomes_axis || 
			this.current_status.stop_interactions){
			return;
		}
		var coords = this.region_plot_container
			.haplotype_region_plot.event_coordinates(event);
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

	updateMargins(){
		this.svg_out
		.attr("width", this.width)
		.attr("height", this.current_status.plot_height);
	    this.region_plot_container.width = this.width;
	    this.region_plot_container.height = this.current_status.plot_height;
	 	this.region_plot_container.update();  
	 	if(this.current_status.display_samples){ 
	 		this.region_score_plot_container.update()
	 	}

	}

	updateStatus(status, disableInteractions){
		this.update_label.text(status);
		this.lock = disableInteractions;
	}

	setupSVG(){    
		var self = this;		
		this.current_status.color = d3.scaleOrdinal(
			['#1b9e77','#d95f02','#7570b3','#e7298a',
			'#e41a1c','#377eb8','#4daf4a','#984ea3',
			'#ff7f00','#a65628','#999999']);		
		this.svg_out = d3.select("#" + this.chartSVGid )
		.append("svg")
		.attr("id", "d3-plot");
		this.region_plot_container = new RegionPlotContainer(this.svg_out, this.width, this.current_status.plot_height, this.current_status, this.margin);
		this.region_plot_container.x = this.x;
		this.region_plot_container.y = this.y;
		this.region_plot_container.x_top = this.x_top;
		this.region_plot_container.margin = this.margin;
		this.update_label = this.svg_out.append("text");
		this.update_label.attr("class", "status_text");
		this.update_label.text("Rendering...");
		if(this.current_status.display_samples){ 
			this.region_score_plot_container = new RegionScorePlotContainer(
				this.svg_out,
				this.width, 
				this.current_status.plot_height, 
				0,
				this.region_plot_container.rendered_height, 
				this.current_status, 
				this.margin)
		}
	}

	renderPlot(){
		this.region_plot_container.renderPlot();	
		if(this.region_score_plot_container){
			this.region_score_plot_container.renderPlot();			
		}
	}

	setBaseAssembly(assembly){

		var tmp_blocks =  this.region_plot_container.haplotype_region_plot.setBaseAssembly(assembly);
		if(this.current_status.selected_blocks === undefined || 
			this.current_status.selected_blocks.length == 0){
			this.current_status.selected_blocks = tmp_blocks;
		}
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
		return this.current_status.range;
	}

	setRange(range){
		var duration     = 500;
		var min_range    = this.region_plot_container.haplotype_region_plot.blocks.shortest_block_length * 2;
		var range_length = range[1] - range[0] ;
		if(range_length < min_range){
			range[0] -= min_range;
			range[1] += min_range
		}
		if(range[1] > this.current_status.max_val){
			range[1] = this.current_status.max_val;
		}
		if(range[0] < 0){
			range[0] = 0;
		}
		this.current_status.start = range[0];
		this.current_status.end   = range[1];	
		this.region_plot_container.region = range ; //TODO: move the code inside to a set of the exposed blocks at this level
		this.x.domain(range);
		this.refresh(duration);
	}

	setScoreRange(range){
		var duration = 500;
		this.y_scores.domain(range);
		this.refresh(duration);
	}

	set region_scores(rs){
		this._region_scores = rs;
	}

	async display_sample(sample, reference, enabled){		
		//var reference = "arinalrfor";
		var id = sample + "-" + reference;
		if(enabled){
			var tmp = await this._region_scores.sample(sample, reference);
			this.region_score_plot_container.addPlot(id, tmp);
			this.current_status.displayed_samples.add(sample);
		}else{
			this.region_score_plot_container.removePlot(id);
			this.current_status.displayed_samples.delete(sample);
			
		}
		this.refresh(500)
	}

	refresh(duration){
		console.log("Refreshing!");
		this.region_plot_container.refresh_range(duration);
		this.region_plot_container.genomes_axis.refresh_range(duration);
		if(this.hap_table){
			this.hap_table.displayZoomed();
		}
		if(this.feat_table){
			this.feat_table.displayZoomed();
		}

		if(this.region_score_plot_container){
			this.region_score_plot_container.refresh_range(duration);
		}
		this.search_box.updateDisplay();
	}
}

window.HaplotypePlot = HaplotypePlot;