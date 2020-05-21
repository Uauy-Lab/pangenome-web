class CurrentStatus{
	constructor(target){
		this.start     = 0;
		this.end       = 0;
		this.position  = -1;
		this.max_val   = 0;
		this.assembly  = null;
		this.roundTo   = 10000;
		this.transitions= 0; 
		this.loaded= false;
		this.target = target;
		this.updating = false;
		this.lock = false;
	}

	round(x){
		return (Math.round(this.target.x.invert(x) / this.roundTo ) * this.roundTo);
	}

	get margin(){
		return this.target.margin
	}

	start_transition(){
		this.transitions++; 
		console.log(this.transitions);
		this.target.updateStatus("...", true);
	}
	
	end_transition(){
		if(--this.transitions === 0 && this.updating == false){
			this.target.updateStatus("", false);

		}
	} 

}

window.CurrentStatus = CurrentStatus;