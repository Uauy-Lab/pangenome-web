import "./region_score";
import "./region_score_set";
import  * as d3 from 'd3'
class RegionScoreContainer{
	constructor(options){
		this.species    = options["species"];
		this.analysis   = options["analysis"];
		this.reference  = options["reference"];
		this.samples    = options["samples"]; //this is an array with all the samples
		this.chromosome = options["chromosome"];
		this.regionSets = new Map();
		this.range_cache_keys = new Set();
		
	};

	async sample(sample, reference){
		var self = this;
		console.log("Loading... " + sample + "-" + reference);
		if(!this.samples.includes(sample)){
			console.warn("Unable to load data for " + sample);
			return false;
		}
		var ret = null;
		var id = sample + "-" + reference;
		if(!this.regionSets.has(id)){

			var path = "../../" + this.species + 
			"/kmer_analysis/" + this.analysis + 
			"/ref/" + reference + 
			"/sample/" + sample + 
			"/chr/" + this.chromosome + ".json";
			var tmp = new RegionScoreSet({
				'name': sample,
				'description:': sample, 
				'json': path,
			})	
			console.log(path);
			console.log(tmp);
			await tmp.readData();
			this.regionSets.set(id, tmp);
		}
		ret = this.regionSets.get(id);
		// console.log(ret);
		return ret;
	};

	checkCacheKeys(keys){
		var equal = true;
		if(keys.size != this.range_cache_keys.size ){
			return false;
		}
		this.range_cache_keys.forEach(k => equal &= keys.has(k)  )
		//keys.forEach(k => equal &= this.range_cache_keys.has(k)  )
		return equal

	}

	get range(){
		var self = this;
		var vals = [];

		var keys = new Set(this.regionSets.keys());
		if(this.checkCacheKeys(keys)){
			return this.cached_range;
		}

		this.regionSets.forEach( (v,k) => {
			vals.push(v.range(self._score) );
		} )


		vals = vals.flat();
		this.cached_range = [d3.min(vals), d3.max(vals)];
		this.range_cache_keys = keys;
		return this.cached_range;
	}

	set score(score){
		this.range_cache_keys = new Set();
		this._score = score;
	}

	

};
window.RegionScoreContainer = RegionScoreContainer;
