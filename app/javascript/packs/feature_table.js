class FeatureTable extends RegionTable{
	constructor(status){
		let columns = [
			{header: "Search",    col: "search_feature", width: "150px", fmt: (v) => v },
			{header: "Feature",   col: "feature", width: "150px", fmt: (v) => v },
			{header: "Assembly",  col: "assembly", width: "100px", fmt: (v) => v },
			{header: "Reference", col: "reference", width: "90px", fmt: (v) => v },
			{header: "Start",     col: "start"   , width: "90px", fmt: (v) => this.int_fmt(v) },
			{header: "End",       col: "end"     , width: "90px", fmt: (v) => this.int_fmt(v) }
		];
		super(status, columns, click_id = "id");
	}

	get displayed_blocks(){
		let rfs = this.status.region_feature_set;
		return rfs.regions;
	}

	click(feature){
		super.click(feature);
		let db = this.displayed_blocks;
		let clicked_feature = db.filter(i => i.feature == feature);
		let hrs = this.status.haplotype_region_set;
		// if(){

		// }
		
		console.log(feature);
		console.log(clicked_feature);
		console.log(hrs);
	}

}
window.FeatureTable = FeatureTable;