class DetailsData{
	constructor(){
		this.position = -1;

	}

	set selected_blocks(blocks){
		this._blocks = blocks;
	}

	get selected_blocks(){
		this._blocks;
	}

}

window.DetailsData = DetailsData;