import "./region_score";
import "./region_score_set";
class RegionScoreContainer{
	constructor(options){
		this.species    = options["species"];
		this.analysis   = options["analysis"];
		this.reference  = options["reference"];
		this.samples    = options["samples"]; //this is an array with all the samples
		this.chromosome = options["chromosome"];
		this.regionSets = new Map();
		console.log(this.samples);
	};

	async sample(sample){
		var self = this;
		console.log("Loading... " + sample);
		if(!this.samples.includes(sample)){
			console.warn("Unable to load data for " + sample);
			return false;
		}
		if(!this.regionSets.has(sample)){

			var path = "http://localhost:3000/" + this.species + 
			"/kmer_analysis/" + this.analysis + 
			"/ref/" + this.reference + 
			"/sample/" + sample + 
			"/chr/" + this.chromosome + ".json";
			var tmp = new RegionScoreSet({
				'name': sample,
				'description:': sample, 
				'json': path,
			})	
			console.log(path);
			console.log(tmp);
			this.regionSets.set(sample, tmp);
		}

		var ret = this.regionSets.get(sample);
		console.log(ret);
		await ret.readData();
		return ret;
	};

};
window.RegionScoreContainer = RegionScoreContainer;
