class HaplotypeTable extends Table{

	constructor(status){
		let columns = [
			{header: "Block_no", col: "block_no", fmt: (v) => v },
			{header: "Assembly", col: "assembly", fmt: (v) => v },
			{header: "Start",    col: "start"   , fmt: (v) => this.int_fmt(v) },
			{header: "End",      col: "end"     , fmt: (v) => this.int_fmt(v) },
			{header: "Length", 	 col: "length"  , fmt: (v) => this.int_fmt(v) }
		];
		super(status, columns);
		this.displayed_blocks = [];
	}

	

	click(block){
		if(!this.status.table_selected_bocks.includes(block)){
			this.status.table_selected_bocks.push(block);
		}else{
			this.status.table_selected_bocks = this.status.table_selected_bocks.filter(item => item !== block)
		}
		this.body.selectAll("tr")
		.classed("row-selected",
			d => this.status.table_selected_bocks.includes(d.block_no))
		.classed("row-non-selected",
			d => !this.status.table_selected_bocks.includes(d.block_no));;
		var hb = this.status.table_selected_bocks.length > 0 ? this.status.table_selected_bocks : this.status.blocks_for_table;
		this.status.target.highlightBlocks(hb);
		
	}

	displayZoomed(){
		var to_show = this.displayed_blocks; 
		to_show = to_show.filter(d => d.inRange(this.status.start, this.status.end));
		this.updateTable(to_show);
	}

	showBlocks(blocks){
		//console.log(blocks);
		var self = this;
		this.displayed_blocks = blocks;
		this.status.table_selected_bocks.length = 0;
		this.displayZoomed();
	}
}

window.HaplotypeTable = HaplotypeTable;