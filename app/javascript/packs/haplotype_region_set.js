import  * as d3 from 'd3'

import "./haplotype_region";

class HaplotypeRegionSet{
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
		const tmp_data = await d3.csv(this.csv_file);
		this.data = tmp_data.map(d => new HaplotypeRegion(d));
		this.start = 0;
		this.end = d3.max(this.data, function(d){return d.end});
		console.log("END:" + this.end); 
		this.setBaseAssembly(false);
	}

	setBaseAssembly(assembly){
		this.clearBlocks();
		var longest = null
		var i = 1;
		asm_blocks = [];

		if(assembly){
			longest = this.findAssemblyBlock(assembly);
			var asm_blocks = this.color_blocks(longest["blocks"], i++, longest["region"].assembly);
			asm_blocks = asm_blocks.concat(longest["blocks"]);	
		}
		
		do{
			longest = this.findLongestBlock();
			if(longest["blocks"].length > 0){
				longest = this.findAssemblyBlock(longest["region"].assembly);
				//this.color_blocks(longest["blocks"], longest["region"].assembly);
				this.color_blocks(longest["blocks"], i++, longest["region"].assembly);
			}
		}while(longest["blocks"].length > 0 )

		return asm_blocks;
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

	merge_blocks(){
		var tmp_data = [];
		var changed = false;
		var current = null;
		var merged_data = this.data;
		var i = 15;
		do{
			changed = false;
			tmp_data = [];
			current = null;
			var size_merged = merged_data.length;
			if(size_merged == 0){
				break;
			}
			for(let d of merged_data ){
				if(d == null ||  d.merged_block > 0){
					continue;
				}
				if(current == null){
					current = new HaplotypeRegion(d);
				}
				if(current.overlap(d)){
					if(current.start > d.start ){
						current.start = d.start;
					}
					if(current.end < d.end){
						current.end = d.end;
					}
				}else{
					tmp_data.push(current);
					current = new HaplotypeRegion(d);
				}
			}
			tmp_data.push(current);
			if(merged_data.length != tmp_data.length){
				merged_data = tmp_data;
				changed = true;
			}
		}while( --i > 0 && changed);
		return merged_data;
	}

	findAssemblyBlock(assembly){
		var assembly_block = null;
		var assembly_arr = [];
		for(let d of this.data){
			if(d.assembly != assembly || d.merged_block > 0){
				continue;
			}
			if(assembly_block == null){
				assembly_block = new HaplotypeRegion(d);
			}
			assembly_arr.push(d.block_no);
			if(assembly_arr.start > d.start){
				assembly_arr.start = d.start;
			}
			if(assembly_arr.end < d.end){
				assembly_arr.end = d.end;
			}
		}
		return {"region": assembly_block, "blocks" : assembly_arr, "length": assembly_block.length()};
	}

	clearBlocks(){
		for(let d of this.data){
			d.merged_block = 0;
		}
	}

	findLongestBlock(){
		var merged_blocks = this.merge_blocks();
		var longest = null;
		var longest_arr = [];
		var longest_size = 0

		for(let d of merged_blocks ){
			if(d == null){
				break;
			}
			if(longest_size < d.length()){
				longest_size = d.length();
				longest = d;
			}
		}
		for(let d of this.data){
			if(d.overlap(longest)){
				longest_arr.push(d.block_no);
			}
		}
		return {"region": longest, "blocks" : longest_arr, "length": longest_size};
	}

	colorContainedBlocks(blocks, id, color_id){
		var more_blocks = [];
		for(let d of this.data){

			if(d == null || d.merged_block > 0){
				continue;
			}
			if(blocks.contains(d)){		
				d.merged_block = id;
				d.color_id = color_id;
				more_blocks.push(d.block_no);
			}
		}
		this.color_blocks(more_blocks, id, color_id);
		return more_blocks;
	}

	color_blocks(blocks, id, color_id){
		var contained_blocks = [];
		var tmp;
		for(let d of this.data){
			if(d.merged_block > 0){
					continue;
			}
			if(blocks.includes(d.block_no)){
				d.merged_block = id;
				d.color_id = color_id;
				tmp = this.colorContainedBlocks(d, id, color_id);
				contained_blocks =  contained_blocks.concat(tmp);
			}
		}
		return contained_blocks;
	}
}



window.HaplotypeRegionSet = HaplotypeRegionSet;