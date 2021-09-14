class EventCoordinates{
	#coords;
	constructor(){
		this.hash         = "";
		this.asm          = undefined;
		this.blocks       = [];
		this.#coords       = [0,0];
		this.in_plot      = false;
		this.in_y_axis    = false;
		this.in_score     = false;
		this.in_haplotype = false;
		this.bp           = undefined;
	}

	get x(){
		return this.#coords[0];
	}

	get y(){
		return this.#coords[1];
	}

	set coords(c){
		this.#coords = c;
	}

	same_blocks(blocks){
		if(this.blocks.length == 0 && blocks.length == 0){
			return true;
		}
		if(this.blocks.length != blocks.length){
			return false;
		}
		let test_1 = blocks.reduce((ret, b) => ret && this.blocks.includes(b) , true)
		let test_2 = this.blocks.reduce((ret, b) => ret && blocks.includes(b) , true)
		return test_1 && test_2;
	}
}

window.EventCoordinates = EventCoordinates;