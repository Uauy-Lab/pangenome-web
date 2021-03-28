//http://localhost:3000//wheat/kmer_analysis/kmerGWAS/ref/arinalrfor/sample/flame_kmerGWAS/chr/1A.json
class RegionFeature extends Region{
	constructor(values){
		super(values);
		this.feature = values['feature'];
		this.search_feature = values['search_feature'];
	}
};


class RegionFeatureSet{
	#url;
	#status;
	#feature_coordinates;
	#highlighted_features;
	#cache;
	#changed;
	#features;
	#last_range;
	#displayed_assemblies;
	constructor(url, status){
		this.#url = url;
		this.#status = status;
		this.#feature_coordinates  = new Map();
		this.#highlighted_features = new Set();
		this.#cache = new Map();
		this.#changed = true;
		this.#features = [];
		this.#last_range = [0,0];
		this.#displayed_assemblies = [];
	}

	coordiante_url(search){
		return `${this.#url}/coordinates/${search}.json`
	}

	async searchCoordinates(search){
		if(!this.has_feature(search)){
			await d3.json(
				this.coordiante_url(search)).then(
					value =>  this.add_feature(value) 	
			)
		}
		this.highlight_feature(search);
	}

	has_feature(feature){
		return this.#feature_coordinates.has(feature)
	}

	add_feature(feature){
		var tmp = feature.mappings.map( f => new RegionFeature(f));
		this.#feature_coordinates.set(feature.feature, tmp);
	}

	highlight_feature(feature){
		this.#highlighted_features.add(feature);
		this.#changed = true;
	}

	unhighlight_feature(feature){
		this.#highlighted_features.delete(feature);
		this.#changed = true;
	}

	async autocomplete(search){
      	if(this.#cache.has(search)){
        	return this.#cache.get(search);
   		}
		await d3.json(`${this.#url}/autocomplete/${search}.json`).then(
			value => this.#cache.set(search, value), 
	        error => console.log(`autocomplete ${error}`)
	    )
    	return this.#cache.get(search);
	}

	get regions(){
		var range = this.#status.range;
		if(range[0] != this.#last_range[0] || 
			range[1] != this.#last_range[1] ){
			this.#changed = true;
		}
		var da = this.#status.displayed_assemblies;
		var da_ids = this.#status.assemblies;
		if(da_ids.length.length != 
			this.#displayed_assemblies.length){
			this.#changed = false;
		}
		if(!this.#changed){
			da.forEach((v,i) => 
				this.#changed &=  v == this.#displayed_assemblies[i] );
		}
		this.#displayed_assemblies = da;
		if(!this.#changed){
			return this.#features;
		}
		this.#last_range = range;
		var ret = [];
		this.#highlighted_features.forEach(
			s => ret.push(this.#feature_coordinates.get(s)
							.filter(f => 
						 		f.inRange(range[0], range[1]) && 
						 		da.get(f.assembly))
			)
		);
		this.#features = ret.flat();
		return this.#features;
	}

}


window.RegionFeature = RegionFeature;
window.RegionFeatureSet = RegionFeatureSet;