class Region{
	constructor(values){
		this.assembly     = values.assembly;
		this.reference    = values.reference;
		this.chromosome   = values.chromosome;
		this.start        = parseInt( values.start);
		this.end          = parseInt(values.end);
	}

	length(){
		return this.end - this.start
	}
	overlap(other){
		if(other == null){
			return false;
		}
		if(other.reference != this.reference){
			return false;
		}
		if(other.chromosome != this.chromosome){
			return false;
		}
		var left  = other.start >= this.start && other.start <= this.end;
		var rigth = this.start >= other.start && this.start <= other.end;
		return  left || rigth; 
	}

	contains(other){
		if(other.assembly != this.assembly){
			return false;
		}
		if(other.chromosome != this.chromosome){
			return false;
		}
		return other.start >= this.start && other.end <= this.end;
	}


	region_string(){
		return "" + this.assembly +":\t" + this.chromosome + ":\t" + this.start + "-\t"  +this.end;
	}
};

class HaplotypeRegion extends Region{
	constructor(values){
		super(values);
		this.block_no     = parseInt(values.block_no);
		this.chr_length   = parseInt(values.chr_length);
		this.merged_block = 0;	
	}
};
window.HaplotypeRegion = HaplotypeRegion;
window.Region = Region;