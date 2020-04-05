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
	this.datasets    = {}
	try{
		this.setDefaultOptions();    
    	jquery.extend(this.opt, options);
    	this.datasets = this.opt["datasets"];
    	this.current_dataset = this.opt["current_dataset"]
    	this._setUserDefaultValues();
    	this.setupDivs();
    	this.setupControlDiv();
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
	this.controlsDIVid = this.opt.target + "_controls"
};

HaplotypePlot.prototype.log_data = function(data){
	for(let d of data){
		console.log(d.region_string());
	}
};


HaplotypePlot.prototype.readData = async function(){
	var   self = this;

	await this.datasets[this.current_dataset].readData();
	await this.renderPlot();
	this.swapDataset(this.current_dataset);
	
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
		bars.transition().
		duration(500).
		style("opacity", 
			function(d) {
			 return blocks.includes(d.block_no)? 1:0.1 
			});	
	}else{
		bars.
		transition().
		duration(500).
		style("opacity", 
			function(d) { 
				return 0.8 
			});
	}
}

HaplotypePlot.prototype.setBaseAssembly = function(assembly){
	
	var asm_blocks = this.datasets[this.current_dataset].setBaseAssembly(assembly);

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


HaplotypePlot.prototype.swapDataset = async function(dataset){
	var self = this;
	this.svg.selectAll("rect").data([]).exit().remove();
	await self.datasets[dataset].readData();
	const data = self.datasets[dataset].data;
	console.log(data);

	var bars = self.svg.selectAll("rect")
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
   	this.current_dataset = dataset;	
   	this.colorPlot();

};

HaplotypePlot.prototype.renderPlot = function(){
	var self = this;
	const data = this.datasets[this.current_dataset].data;
	var assemblies = data.map(d => d.assembly);
	assemblies = [...new Set(assemblies)] ;
	var blocks     = data.map(d => d.block_no);
	blocks = [...new Set(blocks)] ;
	var max_val = d3.max(data,function(d){return d.chr_length})
	
	this.x.domain([0, max_val]).nice();
  	this.y.domain(assemblies);
	this.color.domain(assemblies);
	this.xAxis = d3.axisTop(this.x);
	this.yAxis = d3.axisLeft(this.y);

	this.svg_out.append("g")
	.attr("class", "x axis")
	.call(this.xAxis)
	.attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")")
	.on("mouseover", function(){self.clearHighlight();});

  	this.svg_out.append("g")
	.attr("class", "y axis")
	.attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")")
	.call(this.yAxis);


};

HaplotypePlot.prototype.clearHighlight=function(){
	this.current_asm = "";
	this.highlighted_blocks.length = 0;
	this.highlightBlocks(this.highlighted_blocks);
};

HaplotypePlot.prototype.setupSVG = function(){    

	var self = this;
	var fontSize = this.opt.fontSize;
	this.margin = {top: 50, right: 20, bottom: 10, left: 65};
	var width = this.opt.width - this.margin.left - this.margin.right;
	var height = this.opt.height - this.margin.top - this.margin.bottom;
	//console.log(d3.scaleOrdinal());
	this.y = d3.scaleBand()
	.rangeRound([0, height])
	.padding(0.1);
	this.x = d3.scaleLinear()
	.rangeRound([0, width]);
	this.color = d3.scaleOrdinal(['#1b9e77','#d95f02','#7570b3','#e7298a','#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#a65628','#999999']);
	
	this.svg_out = d3.select("#" + this.chartSVGid ).append("svg")
	.attr("width", this.opt.width)
	.attr("height", this.opt.height)
	.attr("id", "d3-plot")
	

	this.defs = this.svg_out.append("defs")
	this.clip_path = this.defs.append("svg:clipPath").attr("id", "clip");

    this.clip_rect = this.clip_path.append("svg:rect")
      .attr("width", this.opt.width )
      .attr("height", this.opt.height )
      .attr("x", 0)
      .attr("y", 0);

      this.svg = this.svg_out.append("g")
	.attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")")
	.attr("clip-path", "url(#clip)");
	

	
	console.log(this.clip_rect);
};


HaplotypePlot.prototype.setupControlDiv = function(){
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
    	console.log(newData);
    	self.swapDataset(newData);
    	//updateLegend(newData);
	});



};

HaplotypePlot.prototype.setupDivs = function(){
	this.main_div = d3.select("#" + this.opt.target);
	this.controls_div = this.main_div.append("div");
	this.main_div.append("br");
	this.svg_div = this.main_div.append("div");
	this.svg_div.attr("id", this.chartSVGid);

};

window.HaplotypePlot = HaplotypePlot;
