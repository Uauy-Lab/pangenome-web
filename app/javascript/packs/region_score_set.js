class RegionScoreSet{
	constructor(options){
		this.name = options["name"];
		this.description = options["description"];
		this.json_path = options["json"];
		//http://localhost:3000/wheat/kmer_analysis/kmerGWAS/ref/arinalrfor/sample/flame_kmerGWAS/chr/1A.json
		this.data = false;
	};

	async readData(){
		if(this.data != false){
			return;
		}
		this.data =  await d3.json(this.json_path);
		this.parseRegions();
	};

	parseRegions(){
		console.log(this.data);
	};
};



window.RegionScoreSet = RegionScoreSet;
