import "./region_set";
class MappingRegionSet extends RegionSet {
	#region = null; 
	#data_block_no  = new Map();
	#basepath = '/';
	#filter_column = "block_no"
	#csv_file = ".csv"
	#mapping_blocks = [];
	#chromosome_regions = [];
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
		console.log(`Setting region to ${reg}`);
		for(let r of this.#region.subregions(1000000)){
			console.log(r);
			console.log(r.value);
		}
		
		this.data = false;
		this.#csv_file = `${this.#basepath}/chr/${this.#region.chromosome}/start/${this.#region.start}/end/${this.#region.end}.csv`; 
		//localhost:3000/Wheat/mapping/5/chr/chr2B__chi/start/100000000/end/101000000.csv
	}

	get mapping_blocks(){
		return this.#mapping_blocks;
	}
	
	async readData() {
		if (this.data != false) {
			return;
		}
		var tmp_data = await d3.csv(this.#csv_file);
		this.data = tmp_data.map((d) => new MappingRegion(d));
		this.loadBlockRegions();
		this.prepareChromosomeRegions();
		this.finish_reading();
		this.dispatch("load")
	}
	
	loadBlockRegions(){
		var tmp_mapping_blocks = new Map();
		this.#mapping_blocks = [];
		this.data.forEach((d) => {
			var reg = d[this.#filter_column];
			var tmp = Region.parse(reg);
			tmp.assembly  = d.assembly;
			tmp.reference = d.assembly;
			tmp[this.#filter_column] = reg
			tmp_mapping_blocks.set(reg, tmp);
		})
		tmp_mapping_blocks.forEach(d => this.#mapping_blocks.push(d));
	}

	prepareChromosomeRegions(){
		//subregions
		var tmp_chrom = new Map();
		this.#chromosome_regions = [];
		this.#mapping_blocks.forEach((d) => {
			if(! tmp_chrom.get(d.chromosome)){
				tmp_chrom.set(d.chromosome, [])
			}
			tmp_chrom.get(d.chromosome).push(d);
		})
		this.data.forEach((d) => {
			if(! tmp_chrom.get(d.chromosome)){
				tmp_chrom.set(d.chromosome, [])
			}
			tmp_chrom.get(d.chromosome).push(d);
		})
		tmp_chrom.forEach((arr, k) => {
			var reg = new Region(arr[0]);
			reg.start = Math.min(...arr.map(d => d.start ));
			reg.end = Math.max(...arr.map(d => d.end));
			this.#chromosome_regions.push(reg);
		})
	}

	get chromosomes(){
		return this.#chromosome_regions.map(d => d.chromosome);
	}

	get chromosome_regions(){
		return this.#chromosome_regions;
	}

	get longest(){
		return Math.max(...this.#chromosome_regions.map(d=>d.length))
	}

	blocks_for_coordinate(chromosome, position){
		return this.#mapping_blocks
		.filter(reg =>reg.position_in_range(chromosome, position)) 
		.map(reg => reg[this.#filter_column]);
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