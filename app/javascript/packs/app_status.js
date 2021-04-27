class AppStatus{
	constructor(opts){
		this.species     = opts.species;
		this.chromosome  = opts.chromosome;
		this.selected_assembly = null;
		
		this.read_species();
	}

	get selected_species(){
		let species = document.getElementsByClassName("species-select")[0]
		let id = species.value;
		return this.species[id];
	}

	get selected_chromosome(){
		let chr = document.getElementsByClassName('chromosome-select')[0];
		let id  = chr.value;
		return this.selected_species.chromosomes[id];
	}

	change_species(e){
		let value = e.options[e.selectedIndex].value;
		let new_values = this.species[value].chromosomes;
		let chr_selectors = document.getElementsByClassName('chromosome-select');
		for (const selector of chr_selectors){
    		selector.innerHTML = '';
    		for(const chr of new_values){
    			let el   = selector.appendChild( document.createElement('option') );
    			el.text  = chr.name;
    			el.value = chr.id
    		}
		}
	}

	change_chromosome(e){
		let new_values = this.selected_chromosome.hap_sets
		let hap_selectors = document.getElementsByClassName('hap-set-select'); 
		for(const selector of hap_selectors){
			console.log(selector);
			let old_value = selector.selectedIndex;
			console.log(old_value);
			selector.innerHTML = '';
			for(const hap_set of new_values){
				let el   = selector.appendChild(document.createElement('option'));
    			el.text  = hap_set.description;
    			el.value = hap_set.name;
			}
			selector.selectedIndex = old_value;
			
		}
	}

	change_hap_set(e){
		let hap_selectors = document.getElementsByClassName('hap-set-select'); 
		let val = e.value;
		for(const selector of hap_selectors){
			if(selector == e){
				continue;
			}
			const event = new Event('change');
			selector.value = val;		
			selector.dispatchEvent(event);	
		}
	}

	async read_species(){
		this.species = await d3.json("/species.json");
	}

	ready(){
		$('.alert-error').on('click', function(event) { 
			$(this).remove();
		});
		$('.alert-info').on('click', function(event) { 
			$(this).remove();
		});

		setTimeout(() => {
			$('.alert-error').remove();
			$('.alert-info').remove();
		}, 5000);
	}

	alert_error(message){
		let alert_div = document.createElement('div');
		alert_div.classList.add("alert-error");
		alert_div.innerHTML = "<p>"+message+"</p>";
		document.body.appendChild(alert_div);  
		this.ready();
	}

}

window.AppStatus = AppStatus;