class RegionSet{
	constructor(options){
		this.name = options["name"]
		this.description = options["description"]
		this.csv_file = options["csv_file"]
		this.data = false;
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
		this.data.forEach(d => d.all_blocks = this.data);
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

	get shortest_block_length(){
		var arr = this.data.map(d=>d.length)
		return Math.min(...this.data.map(d=>d.length));
	}

	findOverlapingBlocks(haplotype_region){
		 var data = this.data;
		 var block_overlaps = [];
		 for(var i in data){
		 	var d = data[i];
		 	if(haplotype_region.overlap(d)){
		 		block_overlaps.push(d);
		 	}
		 }
		 return block_overlaps;
	}

	set region(range){
		this.start = range[0];
		this.end   = range[1]
	}

	displayData(){
		var self = this;
		var d_data = this.data.filter(function(d){return d.inRange(self.start, self.end)});
		return d_data;
		//return this.data;
	}

	filter_blocks(block_nos){
		var filtered = block_nos === undefined  || block_nos.length == 0 ? this.data : this.data.filter(b => block_nos.includes(b.block_no));
		return filtered.sort((a,b) => a.block_no - b.block_no);
	}

}

window.RegionSet = RegionSet;