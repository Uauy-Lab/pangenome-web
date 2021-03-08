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

	get range(){
		var self = this;
		var vals = [];
		// console.log("---range");
		// console.log(this);
		this.regionSets.forEach( (v,k) => {
			// console.log(k);
			// console.log(v);
			vals.push(v.range(self._score) );
		} )
		// console.log(vals);
		// console.trace();
		vals = vals.flat()
		return [d3.min(vals), d3.max(vals)];
	}

	set score(score){
		this._score = score;
	}

	

};
window.RegionScoreContainer = RegionScoreContainer;
