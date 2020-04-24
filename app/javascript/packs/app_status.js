class AppStatus{
	constructor(opts){
		this.species = opts.species;
		this.chromosome = opts.chromosome;
		console.log(this);
		this.read_species();
	}

	change_species(e){
		let value = e.options[e.selectedIndex].value;
		let text = e.options[e.selectedIndex].text;
		let new_values = this.species[value].chromosomes;
		console.log(new_values);

		let chr_selectors = document.getElementsByClassName('chromosome-select');
		

		for (const selector of chr_selectors){
    		selector.innerHTML = '';
    		for(const chr of new_values){
    			let el = selector.appendChild( document.createElement('option') );
    			el.text = chr.name;
    			el.value = chr.id
    		}
		}
		// console.log(e);
		// console.log(text);
	}

	async read_species(){
		this.species = await d3.json("species.json");
		console.log(this.species);
	}



}

window.AppStatus = AppStatus;