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
		super(status, columns, status.region_feature_set, click_id = "id");
	}

	get displayed_blocks(){
		let rfs = this.status.region_feature_set;
		return rfs.regions;
	}

	click(feature){
		super.click(feature);
		let hrs = this.status.haplotype_region_set;
		let features = this.region_set.filter (this.selected);
		let regions  = hrs.findAllOverlaplingBlocks(features);
		let blocks   = regions.map(f => f.block_no); 
		
		this.status.selected_blocks = regions;
		// this.status.frozen = blocks.length != 0 ;
		// this.target.refresh(500);
		this.status.update_table_and_highlights();
	}

}
window.FeatureTable = FeatureTable;