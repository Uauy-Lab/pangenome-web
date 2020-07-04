
class AssemblyRegionSet extends RegionSet{
	constructor(options){
		super(options);
	}

	async readData(){
		await super.readData();
		
		this.data = this.tmp_data.map(d => {
			let r = new Region(d);
			r.block_no = d.block_no;
			r.chr_length   = parseInt(d.chr_length);
			return r;
		});
		super.finish_reading();

		this.regions = new Map()
	
	}

	regions_under(coords, current_status){
		if(this.data == false){
			return [];
		}
		var assemblies_reference = current_status.assemblies_reference;
		var reference = assemblies_reference.get(coords.asm);
		var base_coord = this.data.filter( r =>
			r.assembly == reference  && 
			r.reference == reference  && 
			r.inRange(current_status.position ) );

		if(base_coord.length != 1){
			return [];
		}
		var block_no = base_coord[0].block_no;
		var mapped_regions = this.data.filter(r => block_no == r.block_no);
		//mapped_regions.append(base_coord[0])
		var ret = [];
		assemblies_reference.forEach((v,k) => {
			let tmp = mapped_regions.filter(r => r.reference == v)[0];
			tmp = Object.assign({}, tmp);
			tmp.assembly = k;
			ret.push(tmp);
		})
		return ret;
	}

}

window.AssemblyRegionSet = AssemblyRegionSet;
