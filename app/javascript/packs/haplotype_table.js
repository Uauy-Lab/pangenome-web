class HaplotypeTable extends RegionTable {
  constructor(status) {
    let columns = [
      { header: "Block_no", col: "block_no", width: "45px", fmt: (v) => v },
      { header: "Assembly", col: "assembly", width: "120px", fmt: (v) => v },
      {
        header: "Start",
        col: "start",
        width: "90px",
        fmt: (v) => this.int_fmt(v),
      },
      { header: "End", col: "end", width: "90px", fmt: (v) => this.int_fmt(v) },
      {
        header: "Length",
        col: "length",
        width: "90px",
        fmt: (v) => this.int_fmt(v),
      },
    ];
    super(status, columns);
  }

  click(block) {
    super.click(block);
    this.status.table_selected_bocks = this.selected;
    this.status.update_table_and_highlights();
    // var hb = this.status.table_selected_bocks.length > 0 ?
    //  	this.status.table_selected_bocks :
    // 	this.status.blocks_for_table;
    // this.status.target.highlightBlocks(hb);
  }
}

window.HaplotypeTable = HaplotypeTable;
