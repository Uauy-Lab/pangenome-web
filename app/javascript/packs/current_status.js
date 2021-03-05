class CurrentStatus{
	constructor(target){
		this.start       = 0;
		this.end         = 0;
		this.position    = -1;
		this.max_val     = 0;
		this._assembly   = null;
		this._selected_assembly = undefined;
		this.roundTo     = 10000;
		this.transitions = 0; 
		this.loaded      = false;
		this.target      = target;
		this.updating    = false;
		this.lock        = false;
		this.frozen      = false;
		this.selected_blocks       = [];
		this.highlighted_blocks    = [];
		this.table_selected_bocks  = [];
		this.current_coord_mapping = undefined;
		this.assemblies_reference  = [];
		this._displayed_assemblies = undefined;
		this.displayed_samples     = []; 
		this.plot_width  = 0;
		this.plot_height = 0;

		this.datasets        = null;
		this.current_dataset = null;
	}

	round(x){
		return (Math.round(this.target.x.invert(x) / this.roundTo ) * this.roundTo);
	}

	// get display_score(){
	// 	return this.target.display_score;
	// }

	get x(){
		return this.target.x;
	}

	get y_scores(){
		return this.target.y_scores;
	}

	get color_axis(){
		return this.target.color;
	}

	get assembly(){
		if(this._selected_assembly !== undefined){
			return this._selected_assembly;
		}
		return this._assembly;
	}

	get coordinate_mapping(){
		// console.log(this.target.coord_mapping);
		// console.log(this.current_coord_mapping);
		return this.target.coord_mapping[this.current_coord_mapping];
	}

	set assembly(asm){
		this._assembly = asm;
	}

	set selected_assembly(asm){
		this._selected_assembly = asm;
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

	get mapped_coords(){
		var self = this;
		var ret = this._mapped_coords;
		if(this._displayed_assemblies && ret && ret.length > 0){
			ret = ret.filter(r=>self._displayed_assemblies.get(r.assembly));
		}
		return ret;
	}



	set display_coords(coords){
		if(coords ){
			if(coords.asm  && coords.x > 0 && coords.blocks.length > 0){
				this._selected_assembly = coords.asm;
			}else{
				this._selected_assembly = undefined;
			}
			this.position = this.target.x.invert(coords.x);
			this._mapped_coords = this.coordinate_mapping;;//.regions_under(coords);
			this._mapped_coords = this._mapped_coords.regions_under(coords, this);
			
		}
	}

	set displayed_assemblies(asm){
		if(asm == undefined){
			this._displayed_assemblies = undefined;
			return;
		}
		this._displayed_assemblies = new Map();
		asm.forEach( a => this._displayed_assemblies.set(a, true));
	}

	get displayed_assemblies(){
		return this._displayed_assemblies;
	}

	setRange(range){
		this.target.setRange(range);
	}

}

window.CurrentStatus = CurrentStatus;