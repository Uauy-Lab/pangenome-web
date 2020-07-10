
class HaplotypeRegion extends Region{
	constructor(values){
		super(values);
		this.block_no     = parseInt(values.block_no);
		this.chr_length   = parseInt(values.chr_length);
		this.merged_block = 0;	

		this.color_map = new Map();

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

	setBaseColor(assembly, color_id){
		this.color_map.set(assembly, color_id);
	}

	set base_assembly(asm){
		this.color_id = this.color_map.get(asm);
	}


};
window.HaplotypeRegion = HaplotypeRegion;
