import  * as d3 from 'd3'
import $ from "jquery";
import jquery from "jquery";


var  HaplotypePlot = function(options) {
try{
    this.setDefaultOptions();    
    jquery.extend(this.opt, options);
    this._setUserDefaultValues();
    this.setupSVG();
    this.readData();
    //this.setupContainer();
    //this.setupButtons();
    //this.setupProgressBar();
    //
    //this.loadExpression(this.opt.data);    
  } catch(err){
    alert('An error has occured');
    console.error(err);
  }   
};

HaplotypePlot.prototype.setDefaultOptions = function(){
	this.opt = {
		'target': 'haplotype_plot', 
		'width': 800, 
		'height':500
	};
};

HaplotypePlot.prototype._setUserDefaultValues = function(){
	this.chartSVGid = this.opt.target + "_SVG"
}

HaplotypePlot.prototype.renderPlot = function(){

}

HaplotypePlot.prototype.readData = async function(){
	const data = await d3.csv(this.opt.csv_file);
	console.log(data);
}

HaplotypePlot.prototype.setupSVG = function(){    

	var self = this;
	var fontSize = this.opt.fontSize;

	var margin = {top: 50, right: 20, bottom: 10, left: 65};
	var width = this.opt.width - margin.left - margin.right;
	var height = this.opt.height - margin.top - margin.bottom;
	console.log(d3.scaleOrdinal());


	this.y = d3.scaleBand()
    .rangeRound([0, height])
    .padding(0.1);

	this.x = d3.scaleLinear()
	.rangeRound([0, width]);

	this.color = d3.scaleOrdinal(d3.schemeCategory10);


	this.xAxis = d3.axisBottom(this.x);

	this.yAxis = d3.axisLeft(this.y);
	
	this.svg = d3.select("#" + this.chartSVGid ).append("svg")
	.attr("width", this.opt.width)
	.attr("height", this.opt.height)
	.attr("id", "d3-plot")
	.append("g")
	.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
	console.log(this.svg);

};

window.HaplotypePlot = HaplotypePlot;
