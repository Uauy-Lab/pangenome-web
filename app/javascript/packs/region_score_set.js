import  * as d3 from 'd3'
class RegionScoreSet{
	constructor(options){
		this.name = options["name"];
		this.description = options["description"];
		this.json_path = options["json"];
		//http://localhost:3000/wheat/kmer_analysis/kmerGWAS/ref/arinalrfor/sample/flame_kmerGWAS/chr/1A.json
		//http://localhost:3000/wheat/kmer_analysis/kmerGWAS/ref/arinalrfor/sample/flame_kmerGWAS/chr/1A.json
		this._data = false;
		this._dataMap = new Map();
		this.parsed  = false;

	};

	async readData(){
		if(this.parsed == true){
			return;
		}
		this._data =  await d3.json(this.json_path);
		// console.log(this._data);
		// console.trace();
		if(!this.parsed){
			this.data.score_keys.forEach( k => {
					var tmp = this._data.scores[k].values.map(r => new RegionScore(r));
					this.data.scores[k].values = tmp;
					this._dataMap.set(this._data.scores[k].name, k);
				});
			this.parsed = true;
		}
		
	};


	range(score){
		score = this.dataMap.get(score);
		// console.log("Getting: ");
		// console.log(score);
		// console.log(this.data.scores[score]);
		var tmp =  this.data.scores[score].values.map(rs => rs.value);
		return [d3.min(tmp), d3.max(tmp)];
	}

	get dataMap(){
		return this._dataMap;

	}

	get data(){
		return this._data;
	}

	values(min,max, score){
		// console.log("values..");
		//console.log(this);
		var vals = this.data.scores[this.dataMap.get(score)].values;
		vals = vals.filter(v => v.start > min && v.start < max )
		//console.log(vals);
		return vals;
	}

	get reference(){
		return this._data.reference;
	}

	get sample(){
		return this._data.sample;
	}

	get title(){
		return `${this.reference} vs ${this.sample}`
	}

};



window.RegionScoreSet = RegionScoreSet;
