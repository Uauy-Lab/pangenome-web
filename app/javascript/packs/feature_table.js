class FeatureTable extends RegionTable {
  constructor(status) {
    let columns = [
      {
        header: "Search",
        col: "search_feature",
        width: "150px",
        fmt: (v) => v,
      },
      { header: "Feature", col: "feature", width: "150px", fmt: (v) => v },
      { header: "Assembly", col: "assembly", width: "100px", fmt: (v) => v },
      { header: "Reference", col: "reference", width: "90px", fmt: (v) => v },
      {
        header: "Start",
        col: "start",
        width: "90px",
        fmt: (v) => this.int_fmt(v),
      },
      { header: "End", col: "end", width: "90px", fmt: (v) => this.int_fmt(v) },
    ];
    super(status, columns, status.region_feature_set, (click_id = "id"));
  }

  get displayed_blocks() {
    let rfs = this.status.region_feature_set;
    return rfs.regions;
  }

  click(feature) {
    super.click(feature);
	//this.status.table_selected_bocks  = [];
    // let hrs = this.status.haplotype_region_set;
    // let features = this.region_set.filter(this.selected);
    // let overlapping = hrs.findAllOverlaplingBlocks(features);
    // console.log(overlapping);
    // let regions =
    //   overlapping.length > 0
    //     ? overlapping
    //     : hrs.findAllOverlaplingBlocks(this.displayed_blocks);
    // let blocks = regions.map((f) => f.block_no);
    // console.log(blocks);
    // //this.status.selected_blocks = blocks;
    // //this.status.update_table_and_highlights(blocks);
	// this.status.table_selected_bocks = blocks;
	this.status.update_table_and_highlights();
  }
}
window.FeatureTable = FeatureTable;
