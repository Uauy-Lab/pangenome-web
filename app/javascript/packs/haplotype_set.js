import  * as d3 from 'd3'
import $ from "jquery";
import jquery from "jquery";


var HaplotypeRegion = function(values){
	this.assembly = values.assembly;
	this.chromosome = values.chromosome;
	this.start =parseInt( values.start);
	this.end = parseInt(values.end);
	this.block_no = parseInt(values.block_no);
	this.chr_length = parseInt(values.chr_length);
	this.merged_block = 0;
};

HaplotypeRegion.prototype.length = function(){
	return this.end - this.start
};

HaplotypeRegion.prototype.overlap = function(other){
	if(other == null){
		return false;
	}
	if(other.assembly != this.assembly){
		return false;
	}
	if(other.chromosome != this.chromosome){
		return false;
	}
	
	var left  = other.start >= this.start && other.start <= this.end;
	var rigth = this.start >= other.start && this.start <= other.end;
	return  left || rigth; 
	
};

HaplotypeRegion.prototype.contains = function(other){
	if(other.assembly != this.assembly){
		return false;
	}
	if(other.chromosome != this.chromosome){
		return false;
	}
	return other.start >= this.start && other.end <= this.end;

};

HaplotypeRegion.prototype.region_string = function(other){
	return "" + this.assembly +":\t" + this.chromosome + ":\t" + this.start + "-\t"  +this.end;
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
	this.chartSVGid = this.opt.target + "_SVG";
};

HaplotypePlot.prototype.log_data = function(data){
	for(let d of data){
		console.log(d.region_string());
	}
};

HaplotypePlot.prototype.merge_blocks = function(){
	var tmp_data = [];
	var changed = false;
	var current = null;
	var merged_data = this.data;
	var i = 15;
	do{
		changed = false;
		tmp_data = [];
		current = null;
		var size_merged = merged_data.length;
		if(size_merged == 0){
			break;
		}
		for(let d of merged_data ){
			if(d == null ||  d.merged_block > 0){
				continue;
			}
			if(current == null){
				current = new HaplotypeRegion(d);
			}
			if(current.overlap(d)){
				if(current.start > d.start ){
					current.start = d.start;
				}
				if(current.end < d.end){
					current.end = d.end;
				}
			}else{
				tmp_data.push(current);
				current = new HaplotypeRegion(d);
			}
		}
		tmp_data.push(current);
		if(merged_data.length != tmp_data.length){
			merged_data = tmp_data;
			changed = true;
		}
	}while( --i > 0 && changed);
	return merged_data;
};

HaplotypePlot.prototype.findAssemblyBlock = function(assembly){
	var assembly_block = null;
	var assembly_arr = [];
	for(let d of this.data){
		if(d.assembly != assembly){
			continue;
		}
		if(assembly_block == null){
			assembly_block = new HaplotypeRegion(d);
		}
		assembly_arr.push(d.block_no);
		if(assembly_arr.start > d.start){
			assembly_arr.start = d.start;
		}
		if(assembly_arr.end < d.end){
			assembly_arr.end = d.end;
		}
	}
	return {"region": assembly_block, "blocks" : assembly_arr, "length": assembly_block.length()};
};

HaplotypePlot.prototype.clearBlocks =function(){
	for(let d of this.data){
		d.merged_block = 0;
	}
};


HaplotypePlot.prototype.findLongestBlock = function(){
	var merged_blocks = this.merge_blocks();
	var longest = null;
	var longest_arr = [];
	var longest_size = 0

	for(let d of merged_blocks ){
		if(d == null){
			break;
		}
		if(longest_size < d.length()){
			longest_size = d.length();
			longest = d;
		}
	}
	for(let d of this.data){
		if(d.overlap(longest)){
			longest_arr.push(d.block_no);
		}
	}
	return {"region": longest, "blocks" : longest_arr, "length": longest_size};
};

HaplotypePlot.prototype.colorContainedBlocks = function(blocks, id){
	var more_blocks = [];
	for(let d of this.data){

		if(d == null || d.merged_block > 0){
			continue;
		}
		if(blocks.contains(d)){
			
			d.merged_block = id;
			more_blocks.push(d.block_no);
		}
	}
	this.color_blocks(more_blocks, id);
	return more_blocks;
}

HaplotypePlot.prototype.color_blocks = function(blocks, id){
	var contained_blocks = [];
	var tmp;
	for(let d of this.data){
		if(d.merged_block > 0){
				continue;
		}
		if(blocks.includes(d.block_no)){
			d.merged_block = id;
			tmp = this.colorContainedBlocks(d, id);
			contained_blocks =  contained_blocks.concat(tmp);
		}
	}
	return contained_blocks;
};

HaplotypePlot.prototype.readData = async function(){
	var   self = this;
	const tmp_data = await d3.csv(this.opt.csv_file);
	this.data = tmp_data.map(d => new HaplotypeRegion(d));
	var longest = null
	var i = 1;
	//longest = this.findAssemblyBlock("norin61");
	//this.color_blocks(longest["blocks"], i++);
	do{
		longest = this.findLongestBlock();
		this.color_blocks(longest["blocks"], i++);
	}while(longest["blocks"].length > 0 )
	console.log("Total blocks: " + i);
	this.renderPlot();
	this.colorPlot();
};

HaplotypePlot.prototype.colorPlot = function(){
	var self = this;
	var bars = this.svg.selectAll("rect");
	bars.style("fill", function(d) { return self.color(d.merged_block); });
};

HaplotypePlot.prototype.highlightBlocks = function(blocks){
	var self = this;
	var bars = this.svg.selectAll("rect");
	bars.style("opacity", function(d) { return blocks.includes(d.block_no)? 1:0.1 });
}

HaplotypePlot.prototype.setBaseAssembly = function(assembly){
	
	this.clearBlocks();
	console.log(assembly);

	var longest = null
	var i = 1;
	longest = this.findAssemblyBlock(assembly);
	var asm_blocks = this.color_blocks(longest["blocks"], i++);
	asm_blocks = asm_blocks.concat(longest["blocks"]);


	do{
		longest = this.findLongestBlock();
		this.color_blocks(longest["blocks"], i++);
	}while(longest["blocks"].length > 0 )
	console.log("Total blocks: " + i);
	//this.renderPlot();
	this.colorPlot();
	this.highlightBlocks(asm_blocks);
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
    .enter();//.append("g").attr("class", "subbar");

    bars.append("rect")
      .attr("height", self.y.bandwidth())
      .attr("x", function(d) { return self.x(d.start); })
      .attr("y", function(d) { return self.y(d.assembly); })
      .attr("width", function(d) { return self.x(d.end) - self.x(d.start); })
      .attr("class","block_bar")
      .attr("class",function(d){return "block-no-" + d.block_no;})
      .on("click", function(d){self.setBaseAssembly(d.assembly);});
      //.style("fill", function(d) { return self.color(d.merged_block); });	
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
