import  * as d3 from 'd3'
import $ from "jquery";
import jquery from "jquery";
import "./haplotype_region";
import "./haplotype_region_set";

var  HaplotypePlot = function(options) {
	this.highlighted_blocks = [];
	this.mouseover_blocks   = [];
	this.current_asm = "";
	this.tmp_asm     = "";
	this.datasets    = []

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


HaplotypePlot.prototype.readData = async function(){
	var   self = this;
	this.datasets[0] = new HaplotypeRegionSet({
		"csv_file": 
		self.opt["csv_file"]});
	await this.datasets[0].readData();
	console.log("aaaaaaa");
	console.log(this.datasets[0]);
	this.renderPlot();
	this.colorPlot();
};

HaplotypePlot.prototype.colorPlot = function(){
	var self = this;
	var bars = this.svg.selectAll("rect");
	bars.style("fill", function(d) { 
		return self.color(d.color_id); 
	});
};

HaplotypePlot.prototype.highlightBlocks = function(blocks){
	var self = this;
	var bars = this.svg.selectAll("rect");
	if(blocks.length > 0){
		bars.transition().duration(500).style("opacity", function(d) { return blocks.includes(d.block_no)? 1:0.1 });	
	}else{
		bars.transition().duration(500).style("opacity", function(d) { return 0.8 });
	}
}

HaplotypePlot.prototype.setBaseAssembly = function(assembly){
	
	var asm_blocks = this.datasets[0].setBaseAssembly(assembly);

	this.colorPlot();
	this.highlightBlocks(asm_blocks);
	this.highlighted_blocks = asm_blocks;
};



HaplotypePlot.prototype.mouseOverHighlight = function(event,d){
	if(d.assembly != this.tmp_asm){
		this.tmp_asm = d.assembly;
		this.setBaseAssembly(d.assembly);
	}
	var self = this;
	var blocks =  this.blocksUnderMouse(event); 
	var b_new  = blocks.filter(x => !self.mouseover_blocks.includes(x));
	var b_lost = this.mouseover_blocks.filter(x => !blocks.includes(x));
	if(b_new.length + b_lost.length > 0) {
		this.mouseover_blocks = blocks;
		this.highlightBlocks(this.mouseover_blocks);	
	}
	
};

HaplotypePlot.prototype.mouseOutHighlight = function(haplotype_region){
	this.mouseover_blocks.length = 0
	this.highlightBlocks(this.highlighted_blocks);
};

HaplotypePlot.prototype.blocksUnderMouse = function(event){
    var elem = document.elementsFromPoint(event.clientX, event.clientY);
   	var blocks = elem.map(e =>  e.getAttribute("block-no")).filter(a => a);
   	blocks = blocks.map(e=>parseFloat(e));
   	return blocks; 
};

HaplotypePlot.prototype.renderPlot = function(){
	var self = this;
	const data = this.datasets[0].data;
	console.log("SSSS")
	console.log(data);
	var assemblies = data.map(d => d.assembly);
	assemblies = [...new Set(assemblies)] ;
	var blocks     = data.map(d => d.block_no);
	blocks = [...new Set(blocks)] ;
	var max_val = d3.max(data,function(d){return d.chr_length})
	//console.log(max_val);
	this.x.domain([0, max_val]).nice();
  	this.y.domain(assemblies);
	//this.color.domain(blocks);
	this.color.domain(assemblies);
	//console.log("color domain");
	//console.log(assemblies);
	this.xAxis = d3.axisTop(this.x);
	this.yAxis = d3.axisLeft(this.y);

	this.svg.append("g")
	.attr("class", "x axis")
	.call(this.xAxis)
	.on("mouseover", function(){self.clearHighlight();});

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
      .attr("block-no", function(d){return d.block_no;})
      .attr("block-asm",function(d){return d.assembly;})
      .on("mousemove", function(d){
      	self.mouseOverHighlight(d3.event, d); 	
      })
      .on("mouseout",  function(d){self.mouseOutHighlight(d) ;})
      .on("click", function(d){
      	self.current_asm = d.assembly;
      	self.setBaseAssembly(d.assembly);
      });
      //.style("fill", function(d) { return self.color(d.assembly);});	
};

HaplotypePlot.prototype.clearHighlight=function(){
	this.current_asm = "";
	this.highlighted_blocks.length = 0;
	this.highlightBlocks(this.highlighted_blocks);
};

HaplotypePlot.prototype.setupSVG = function(){    

	var self = this;
	var fontSize = this.opt.fontSize;
	var margin = {top: 50, right: 20, bottom: 10, left: 65};
	var width = this.opt.width - margin.left - margin.right;
	var height = this.opt.height - margin.top - margin.bottom;
	//console.log(d3.scaleOrdinal());
	this.y = d3.scaleBand()
	.rangeRound([0, height])
	.padding(0.1);
	this.x = d3.scaleLinear()
	.rangeRound([0, width]);
	this.color = d3.scaleOrdinal(['#1b9e77','#d95f02','#7570b3','#e7298a','#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#a65628','#999999']);
	this.svg = d3.select("#" + this.opt.target ).append("svg")
	.attr("width", this.opt.width)
	.attr("height", this.opt.height)
	.attr("id", "d3-plot")
	.append("g")
	.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
	console.log(this.svg);
};

window.HaplotypePlot = HaplotypePlot;
