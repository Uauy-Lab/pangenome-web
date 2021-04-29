class HaplotypeTable extends RegionTable{

	constructor(status){
		let columns = [
			{header: "Block_no", col: "block_no", width: "45px" , fmt: (v) => v },
			{header: "Assembly", col: "assembly", width: "120px" , fmt: (v) => v },
			{header: "Start",    col: "start"   , width: "90px" , fmt: (v) => this.int_fmt(v) },
			{header: "End",      col: "end"     , width: "90px" , fmt: (v) => this.int_fmt(v) },
			{header: "Length", 	 col: "length"  , width: "90px" , fmt: (v) => this.int_fmt(v) }
		];
		super(status, columns);
		
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
		var hb = this.status.table_selected_bocks.length > 0 ?
		 	this.status.table_selected_bocks : 
			this.status.blocks_for_table;
		this.status.target.highlightBlocks(hb);
	}
	
}

window.HaplotypeTable = HaplotypeTable;