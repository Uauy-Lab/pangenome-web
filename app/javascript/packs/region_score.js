//http://localhost:3000//wheat/kmer_analysis/kmerGWAS/ref/arinalrfor/sample/flame_kmerGWAS/chr/1A.json
class RegionScore extends Region{
	constructor(values){
		super(values);
		this.value = values['value'];
	}
};


//class RegionScore

window.RegionScore = RegionScore;