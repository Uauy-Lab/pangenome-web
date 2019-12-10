import  * as d3 from 'd3'
import $ from "jquery";
import jquery from "jquery";


var HaplotypeRegion = function(values){
	this.assembly = values.assembly;
	this.chromosome = values.chromosome;
	this.start = values.start;
	this.end = values.end;
	this.block_no = values.block_no;
	this.chr_length = values.chr_length;
	this.merged_block = 0;
};

HaplotypeRegion.prototype.length = function(){
	return this.end - this.start
}

HaplotypeRegion.prototype.overlap = function(other){
	var ret = other.assembly == this.assembly;
	ret &= other.chromosome == this.chromosome;
	ret &= (other.start >= this.start && other.start <= this.end) || (this.start >= other.start && this.start <= other.end); 
	return ret;
}

HaplotypeRegion.prototype.region_string = function(other){
	return "" + this.assembly +":" + this.chromosome + ":" + this.start + "-"  +this.end;
}

var  HaplotypePlot = function(options) {
try{
    this.setDefaultOptions();    
    jquery.extend(this.opt, options);
    this._setUserDefaultValues();
    this.setupSVG();
    this.readData();
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
};


HaplotypePlot.prototype.merge_blocks = function(){
	var tmp_data = [];
	var changed = false;
	var current = null;
	var merged_data = this.data;
	console.log("MERGING!");
	do{
		changed = false;
		console.log(merged_data);
		for(let d of merged_data){
			if(d.merged_block > 0){
				continue;
			}
			if(current == null){
				current = new HaplotypeRegion(d);
			}
			console.log(current.region_string());
			if(current.overlap(d)){
				current.end = d.end;
				changed = true;
			}else{
				tmp_data.push(current);
				current = new HaplotypeRegion(d);
				
			}

		}
		if(changed){
			merged_data = tmp_data;
		}
		console.log("________________________");
	}while(changed);
	console.log(merged_data);
	return merged_data;
};


HaplotypePlot.prototype.find_longest_block = function(){
	var previous = null;
	var current = new HaplotypeRegion({});
	var current_arr = [];
	var longest = new HaplotypeRegion({});
	var longest_arr = [];
	var changed = false;
	current.start = 0;
	current.end   = 0;

	longest.start = 0;
	longest.end   = 0;


	do{
		changed = false;
		for(let d of this.data){
			if(d.merged_block > 0){
				continue;
			}
			console.log(d.region_string());
			if(current.overlap(d)){
				current.end = d.end;
				current_arr.push(d.block_no);
				console.log("Overlaps!" + d.region_string()  + " ... " + current.region_string());
			}else{
				console.log("..................");
				if(current.length() > longest.length()){
					console.log("Assigning longest: " + current.region_string());
					longest = current;
					longest_arr = current_arr;
					changed = true;
				}
				current = new HaplotypeRegion(d);
				current_arr = [];
			}
		}

	}while(changed);
	
	return {"region": longest, "blocks" : longest_arr};
};


HaplotypePlot.prototype.readData = async function(){
	var   self = this;
	const tmp_data = await d3.csv(this.opt.csv_file);
	this.data = tmp_data.map(d => new HaplotypeRegion(d));
	var merged = this.merge_blocks();
	//var longest = this.find_longest_block();
	//console.log(longest);
	this.renderPlot();
};

HaplotypePlot.prototype.renderPlot = function(){
	var self = this;
	const data = this.data;
	var assemblies = data.map(d => d.assembly);
	assemblies = [...new Set(assemblies)] ;
	var blocks     = data.map(d => d.block_no);
	blocks = [...new Set(blocks)] ;
	var max_val = d3.max(data,function(d){return d.chr_length})
	console.log(max_val);
	this.x.domain([0, max_val]).nice();
  	this.y.domain(assemblies);
	this.color.domain(blocks);

	this.xAxis = d3.axisTop(this.x);
	this.yAxis = d3.axisLeft(this.y);

	this.svg.append("g")
      .attr("class", "x axis")
      .call(this.xAxis);

  	this.svg.append("g")
      .attr("class", "y axis")
      .call(this.yAxis);

    var bars = this.svg.selectAll("rect")
    .data(data)
    .enter().append("g").attr("class", "subbar");

    bars.append("rect")
      .attr("height", self.y.bandwidth())
      .attr("x", function(d) { return self.x(d.start); })
      .attr("y", function(d) { return self.y(d.assembly); })
      .attr("width", function(d) { return self.x(d.end) - self.x(d.start); })
      .style("fill", function(d) { return self.color(d.merged_block); });	
};

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


	
	
	this.svg = d3.select("#" + this.opt.target ).append("svg")
	.attr("width", this.opt.width)
	.attr("height", this.opt.height)
	.attr("id", "d3-plot")
	.append("g")
	.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
	
	console.log(this.svg);

};

window.HaplotypePlot = HaplotypePlot;
