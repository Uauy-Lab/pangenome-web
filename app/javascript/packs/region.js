class Region{
	constructor(values){
		this.assembly     = values.assembly;
		this.reference    = values.reference;
		this.chromosome   = values.chromosome;
		this.start        = parseInt( values.start);
		this.end          = parseInt(values.end);
	}

	get length(){
		return this.end - this.start
	}

	get id(){
		return this.assembly + ":" + this.reference + ":" +  this.chromosome + ":" +  this.start + ":" + this.end
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

	containsAll(others){
		for(let d of others){
			if(!this.contains(d)){
				return false;
			}
		}
		return true;
	}


	region_string(){
		return "" + this.assembly +":\t" + this.chromosome + ":" + this.start + "-\t"  +this.end;
	}

	inRange(start, end){
		var left  = this.start <= start && this.end >= start 
		var right = this.start <= end   && this.end >= end 
		var contained =  this.start >= start && this.end <= end
		return  left || right || contained; 
	}
};
window.Region = Region;