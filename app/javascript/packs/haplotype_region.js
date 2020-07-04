
class HaplotypeRegion extends Region{
	constructor(values){
		super(values);
		this.block_no     = parseInt(values.block_no);
		this.chr_length   = parseInt(values.chr_length);
		this.merged_block = 0;	
	}

	get id(){
		return super.id + ":" + this.block_no;
	}

	set all_blocks(blocks){
		this._all_blocks = blocks.filter(  b2 => ( 
			this.block_no == b2.block_no &&
			this.assembly == b2.assembly  )  )
	}

	get all_blocks(){
		return this._all_blocks;
	}


};
window.HaplotypeRegion = HaplotypeRegion;
