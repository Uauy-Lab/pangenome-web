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
import "./mapping_coordinates_region_set"
import "./mapping_coordinate_plot_container"
//import * as BaseLogic from "../baseLogic";

class MappingCoordinatesPlot{
	#mapping_region_set;
	#region_plot_container;
	constructor(options){
		this.setDefaultOptions();
		jquery.extend(this.opt, options);
		//path="/Wheat/pangenome_mapping/5/chr/chr2B__chi/start/685850001/end/686150000.csv"
		this.current_status = new CurrentStatus(this);
		this.#mapping_region_set = new MappingRegionSet(options);
		console.log(this.#mapping_region_set);
		this.setupDivs();
		this.setupSVG();
		console.log("hiiii");
		this.setupRanges();
		this.setupSVGInteractions();

		this.#mapping_region_set.on("load", (mrs) => this.update());
		this.#mapping_region_set.readData();
	}

	setupRanges(){
		this.margin = {top: 50, right: 20, bottom: 10, left: 150, virtual_plot_height:100};
		var width  = this.width      - this.margin.left - this.margin.right;
		var height = this.opt["height"] - this.margin.top  - this.margin.bottom;
		this.current_status.plot_height = height;
		this.plot_width  = width;
		this.plot_height = height;
		this.y = d3.scaleBand()
		.padding(0.1).rangeRound([0,height]);
		this.x     = d3.scaleLinear().rangeRound([0, width]);
		this.#region_plot_container.x = this.x;
		this.#region_plot_container.y = this.y;

	}

	setDefaultOptions (){
		this.opt = {
			'target': 'mapping_plot', 
			'width': 800, 
			'height':1000,
			'name' : "Test download"
		}
	}

	setupDivs(){
		this.chartSVGid = this.opt.target + "_SVG";
		this.main_div = d3.select("#" + this.opt.target);
		this.svg_div = this.main_div.append("div");
		this.svg_div.attr("id", this.chartSVGid);
		this.svg_div.classed("haplotype-plot", true);
	}

	mousemove(event){
		let coords = this.#region_plot_container.event_coordinates(event);
		console.log(coords);
	}

	setupSVGInteractions(){
		this.svg_out.on("mousemove", () => this.mousemove(d3.event));
	}

	get width(){
		var element = this.svg_div.node();
		return element.getBoundingClientRect().width;
	}

  get height(){
	  var element = this.svg_div.node();
	  return element.getBoundingClientRect().height;
  }

  setupSVG(){    
	// var self = this;		
	// this.current_status.color = d3.scaleOrdinal(
	// 	['#1b9e77','#d95f02','#7570b3','#e7298a',
	// 	'#e41a1c','#377eb8','#4daf4a','#984ea3',
	// 	'#ff7f00','#a65628','#999999']);		
	this.svg_out = d3.select("#" + this.chartSVGid )
	.append("svg")
	.attr("id", `plot-${this.chartSVGid}`);
	this.#region_plot_container = new MappingCoordinatePlotContainer(this.svg_out, this.width, this.height, 0, 5, this.current_status);
	this.#region_plot_container.mapping_region_set = this.#mapping_region_set;
  }

  update(){
	  console.log("Updatiiiing");
	  console.log(this.svg_div);
	  console.log(this.width);
	  console.log(this.plot_height);
	  this.svg_out.attr("height", this.plot_height).attr("width", this.width);
	  this.svg_div
	  .attr("width", this.width)
	  .attr("height", this.plot_height);
	  this.#region_plot_container.width = this.width;
	  this.#region_plot_container.height = this.current_status.plot_height;
	  this.#region_plot_container.update();
  }
};

window.MappingCoordinatesPlot = MappingCoordinatesPlot;