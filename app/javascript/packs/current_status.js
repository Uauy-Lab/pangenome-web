class CurrentStatus{
	constructor(target){
		this.start     = 0;
		this.end       = 0;
		this.position  = -1;
		this.max_val   = 0;
		this._assembly  = null;
		this.roundTo   = 10000;
		this.transitions= 0; 
		this.loaded= false;
		this.target = target;
		this.updating = false;
		this.lock = false;
		this.frozen = false;
		this.selected_blocks = [];
		this.highlighted_blocks = [];
		this.table_selected_bocks = [];
	}

	round(x){
		return (Math.round(this.target.x.invert(x) / this.roundTo ) * this.roundTo);
	}

	get assembly(){
		return this._assembly;
	}

	set assembly(asm){
		// console.log("Changing..." + asm);
		// console.trace();
		this._assembly = asm;
	}

	get margin(){
		return this.target.margin
	}

	get stop_interactions(){
		return this.lock || this.frozen || this.transitions;
	}

	get blocks_for_table(){
		return this.selected_blocks.length > 0 ? this.selected_blocks : this.highlighted_blocks;
	}

	get blocks_for_highlight(){
		return this.table_selected_bocks > 0 ? this.table_selected_bocks : this.blocks_for_table;

	}

	start_transition(){
		this.transitions++; 
		this.target.updateStatus("...", true);
	}
	
	end_transition(){
		if(--this.transitions === 0 && this.updating == false){
			this.target.updateStatus("", false);
		}
	} 

	toggle_frozen(){
		this.frozen = !this.frozen;
	}

}

window.CurrentStatus = CurrentStatus;