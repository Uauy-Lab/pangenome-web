
class MappingRegion extends Region{
	constructor(values){
		super(values);
		this.block_no     = values.block_no;
		// this.chr_length   = parseInt(values.chr_length);
		this.merged_block = 0;	
		
	}

	get id(){
		return super.id + ":" + this.block_no;
	}

};
window.MappingRegion = MappingRegion;
