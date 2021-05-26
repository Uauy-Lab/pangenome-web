class RegionSet{
	#filter_column;
	#data_block_no;
	#selected_ids = [];
	constructor(options, filter_column="block_no"){
		this.name = options["name"];
		this.description = options["description"];
		this.csv_file = options["csv_file"];
		this.data = false;
		this.#filter_column = filter_column;
	}

	async readData(){
		if(this.data != false){
			return;
		}
		var   self = this;
		this.tmp_data = await d3.csv(this.csv_file);
		this.preare_chromosome_lengths(this.tmp_data);
	}

	finish_reading(){
		this.#data_block_no = new Map();
		this.data_asm = new Map();
		this.data.forEach(d => {
			d.all_blocks = this.data;
			if(!this.#data_block_no.has(d[this.#filter_column])){
				this.#data_block_no.set(d[this.#filter_column], []);
			}
			if(!this.data_asm.has(d.assembly)){
				this.data_asm.set(d.assembly, []);
			}
			this.#data_block_no.get(d[this.#filter_column]).push(d);
			this.data_asm.get(d.assembly).push(d);
		});
		this.start = 0;
		this.end = d3.max(this.chromosomes_lengths, function(d){return d.length});
	}

	preare_chromosome_lengths(data){
		this.chromosomes_lengths ={}
		for(let d of data){
			var reg = new Region(d);
			reg.start = 0;
			reg.end = parseInt(d.chr_length);
			this.chromosomes_lengths[reg.assembly] = reg;
		}
		this.chromosomes_lengths = Object.values(this.chromosomes_lengths);
	}

	get assemblies(){
		return this.chromosomes_lengths.map(obj => { return obj.assembly});
	}

	get shortest_block_length(){
		var arr = this.data.map(d=>d.length)
		return Math.min(...this.data.map(d=>d.length));
	}
	/**
	 * 
	 * @param {Region[]} regions 
	 * @returns {HaplotypeRegion[]}
	 */
	findAllOverlaplingBlocks(regions){
		return regions.map(r => this.findOverlapingBlocks(r)).flat();
	}

	findOverlapingBlocks(region){
		// console.log("finding overlap for...");
		// console.log(region);
		 var data = this.data;
		 var block_overlaps = [];
		 for(var i in data){
		 	var d = data[i];
		 	if(region.overlap(d)){
		 		block_overlaps.push(d);
		 	}
		 }
		 return block_overlaps;
	}

	/**
	 * @param {FixedLengthArray<2, Number>} range
	 */
	set region(range){
		this.start = range[0];
		this.end   = range[1]
	}

	displayData(current_status){
		var self = this;
		var d_data = this.data.filter(function(d){return d.inRange(self.start, self.end)});
		if(current_status){
			d_data = d_data.filter( d => current_status.displayed_assemblies.get(d.assembly));
		}
		return d_data;
		//return this.data;
	}

	displayChromosomes(current_status){
		var self = this;
		var d_data = this.chromosomes_lengths;
		//var d_data = this.data.filter(function(d){return d.inRange(self.start, self.end)});
		if(current_status){
			d_data = d_data.filter( d => current_status.displayed_assemblies.get(d.assembly));
		}
		return d_data;
		//return this.data;
	}

	filter(select_ids){
		var filtered = select_ids === undefined  || select_ids.length == 0 ?
				 this.data : 
				 this.data.filter(
					b => select_ids.includes(b[this.#filter_column])
				);
		return filtered.sort((a,b) => a[this.#filter_column] - b[this.#filter_column] );
	}

	get data_block_no(){
		return this.#data_block_no;
	}

	toggle(data_id){
		if(!this.#selected_ids.includes(data_id)){
			this.#selected_ids.push(data_id);
		}else{
			this.#selected_ids = this.#selected_ids.filter(
				item => item !== data_id)
		}

	}

	get select_ids(){
		return this.#selected_ids;
	}

}

window.RegionSet = RegionSet;