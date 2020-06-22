import  * as d3 from 'd3'
import 'd3-extended'
import "./haplotype_region";
import "./region_set";

class HaplotypeRegionSet extends RegionSet{
	constructor(options){
		super(options);
	}

	setBaseAssembly(assembly){
		if(this.base_assembly == assembly){
		 	return this.asm_blocks;
		}
		this.clearBlocks();
		var longest = null
		var i = 1;
		this.asm_blocks = [];

		if(assembly){
			longest = this.findAssemblyBlock(assembly);
			this.asm_blocks = this.color_blocks(longest["blocks"], i++, longest["region"].assembly);
			this.asm_blocks = this.asm_blocks.concat(longest["blocks"]);	
		}
		do{
			longest = this.findLongestBlock();
			if(longest["blocks"].length > 0){
				longest = this.findAssemblyBlock(longest["region"].assembly);
				this.color_blocks(longest["blocks"], i++, longest["region"].assembly);
			}
		}while(longest["blocks"].length > 0 )
		//console.log(this.asm_blocks);
		this.base_assembly = assembly;
		return this.asm_blocks;
	}


	set region(range){
		this.start = range[0];
		this.end   = range[1]
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
			if(current) tmp_data.push(current);
			if(merged_data.length != tmp_data.length){
				merged_data = tmp_data;
				changed = true;
			}
		}while( --i > 0 && changed);
		return merged_data;
	}

	findAssemblyBlock(assembly){
		var filtered_blocks = this.data
		.filter( d => d.merged_block == 0 && d.assembly == assembly )
		var assembly_arr = filtered_blocks.map( d => d.block_no);
		var assembly_block = filtered_blocks[0];
		return {"region": assembly_block, "blocks" : assembly_arr	};
	}

	clearBlocks(){
		for(let d of this.data){
			d.merged_block = 0;
		}
	}

	findLongestBlock(){
		var merged_blocks = this.merge_blocks();
		var longest_arr = [];
		var longest = merged_blocks.reduce( 
			(longest, d) => d.length > longest.length ? d : longest,
			merged_blocks[0]);
		merged_blocks.forEach( d =>{
			if ( d.overlap(longest)) {longest_arr.push(d.block_no)} } );
		return {"region": longest, "blocks" : longest_arr, "length": longest ?  longest.length: 0};
	}

	colorContainedBlocks(blocks, id, color_id){
		var more_blocks = [];
		for(let d of this.data){
			if(d == null || d.merged_block > 0){
				continue;
			}

			let ds = d.all_blocks;
			if(blocks.containsAll(ds)){		
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