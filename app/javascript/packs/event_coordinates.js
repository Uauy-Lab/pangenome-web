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
}

window.EventCoordinates = EventCoordinates;