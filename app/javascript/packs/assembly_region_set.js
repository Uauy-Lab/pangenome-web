
class AssemblyRegionSet extends RegionSet{
	constructor(options){
		super(options);
	}

	async readData(current_status){
		await super.readData();
		
		this.data = this.tmp_data.map(d => {
			let r = new Region(d);
			r.block_no = d.block_no;
			r.chr_length   = parseInt(d.chr_length);
			return r;
		});
		super.finish_reading();

		var assemblies_reference = current_status.assemblies_reference;
		this.mapped_regions = new Map();
		this.data_block_no.forEach((mapped_regions, block_no) => {
			let ret = [];
			assemblies_reference.forEach((v,k) => {
				let tmp = mapped_regions.filter(r => r.reference == v)[0];
				if(tmp){
					let id = tmp.id
					tmp = Object.assign({}, tmp);
					tmp.assembly = k;
					tmp.id = id;
					ret.push(tmp);		
				}
			});
			this.mapped_regions.set(block_no, ret);
		});
	}

	regions_under(coords, current_status){
		if(this.data == false){
			return [];
		}

		var assemblies_reference = current_status.assemblies_reference;
		var reference = assemblies_reference.get(coords.asm);
		if(!this.data_asm.has(reference)){
			return [];
		}

		var base_coord = this.data_asm.get(reference).filter( r => 
			r.reference == reference  && 
			r.inRange(current_status.position ) );

		if(base_coord.length != 1){
			return [];
		}
		var block_no = base_coord[0].block_no;
		
		return this.mapped_regions.get(block_no);
		
	}

}

window.AssemblyRegionSet = AssemblyRegionSet;
