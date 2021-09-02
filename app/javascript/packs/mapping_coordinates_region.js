
class MappingRegion extends Region{
	constructor(values){
		super(values);
		this.block_no     = values.block_no;		
	}

	get id(){
		return super.id + ":" + this.block_no;
	}

};
window.MappingRegion = MappingRegion;
