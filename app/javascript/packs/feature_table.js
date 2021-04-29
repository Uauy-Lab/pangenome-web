class FeatureTable extends RegionTable{
	constructor(status){
		let columns = [
			{header: "Search", col: "search_feature", fmt: (v) => v },
			{header: "Feature", col: "feature", fmt: (v) => v },
			{header: "Assembly", col: "assembly", fmt: (v) => v },
			{header: "Reference", col: "reference", fmt: (v) => v },
			{header: "Start",    col: "start"   , fmt: (v) => this.int_fmt(v) },
			{header: "End",      col: "end"     , fmt: (v) => this.int_fmt(v) },
			{header: "Length", 	 col: "length"  , fmt: (v) => this.int_fmt(v) }
		];
		super(status, columns);
		console.log("....")
		console.log(this);
	}

	get displayed_blocks(){
		let rfs = this.status.region_feature_set;
		return rfs.regions;
	}

}
window.FeatureTable = FeatureTable;