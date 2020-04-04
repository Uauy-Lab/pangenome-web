

var HaplotypeRegion = function(values){
	this.assembly     = values.assembly;
	this.reference    = values.reference;
	this.chromosome   = values.chromosome;
	this.start        = parseInt( values.start);
	this.end          = parseInt(values.end);
	this.block_no     = parseInt(values.block_no);
	this.chr_length   = parseInt(values.chr_length);
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

HaplotypeRegion.prototype.region_string = function(){
	return "" + this.assembly +":\t" + this.chromosome + ":\t" + this.start + "-\t"  +this.end;
}

window.HaplotypeRegion = HaplotypeRegion;