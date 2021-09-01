import "./region_set";
class MappingRegionSet extends RegionSet {
	#region = null; 
	#data_block_no  = new Map();
	#basepath = '/';
	#filter_column = "block_no"
	#csv_file = ".csv"
	constructor(options) {
		super(options);
		this.#basepath = options.path;
		this.region = options.region;
	}
	
	/**
	 * @param {String} reg
	 */
	set region(reg){
		this.#region = Region.parse(reg);
		this.data = false;
		this.#csv_file = `${this.#basepath}/chr/${this.#region.chromosome}/start/${this.#region.start}/end/${this.#region.end}.csv`; 
		//localhost:3000/Wheat/mapping/5/chr/chr2B__chi/start/100000000/end/101000000.csv
	}
	
	async readData() {
		if (this.data != false) {
			return;
		}
		var tmp_data = await d3.csv(this.#csv_file);
		this.data = tmp_data.map((d) => new MappingRegion(d));
		this.finish_reading();
	}
	
	preare_chromosomes(data) {
		this.chromosomes_lengths = {};
		for (let d of data) {
			var reg = new Region(d);
			reg.start = 0;
			reg.end = parseInt(d.chr_length);
			this.chromosomes_lengths[reg.assembly] = reg;
		}
		this.chromosomes_lengths = Object.values(this.chromosomes_lengths);
	}

	finish_reading() {
		this.#data_block_no = new Map();
		this.data_asm = new Map();
		this.data.forEach((d) => {
		  d.all_blocks = this.data;
		  if (!this.#data_block_no.has(d[this.#filter_column])) {
			this.#data_block_no.set(d[this.#filter_column], []);
		  }
		  if (!this.data_asm.has(d.assembly)) {
			this.data_asm.set(d.assembly, []);
		  }
		  this.#data_block_no.get(d[this.#filter_column]).push(d);
		  this.data_asm.get(d.assembly).push(d);
		});
	  }
	
}

window.MappingRegionSet = MappingRegionSet;