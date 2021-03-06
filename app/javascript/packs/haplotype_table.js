class HaplotypeTable{

	constructor(status){
		this.status = status;
		var num_fmt = d3.format(",.5r");
		this.columns = [
			{header: "Block_no", col: "block_no", fmt: (v) => v },
			{header: "Assembly", col: "assembly", fmt: (v) => v },
			{header: "Start",    col: "start"   , fmt: (v) => num_fmt(v) },
			{header: "End",      col: "end"     , fmt: (v) => num_fmt(v) },
			{header: "Length", 	 col: "length"  , fmt: (v) => num_fmt(v) }
		];

		this.displayed_blocks = [];
	}

	renderTable(div){
		this.div = div;

		this.table_head = this.div.append("div").classed("tbl-header", true).append("table");
		this.head = this.table_head.append('thead').append('tr')
   		.selectAll('th')
   		.data(this.columns).enter()
   		.append('th')
   		.text(d => d.header);
   		this.table_body = this.div.append("div").classed("tbl-content", true).append("table")
   		this.body = this.table_body.append("tbody");

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
		this.body.selectAll("tr")
		.data(to_show)
		.join(
			enter =>
				enter.append("tr")
				.classed("row-selected",
					d => this.status.table_selected_bocks.includes(d.block_no))
				.on("click", d => this.click(d["block_no"]))
				.selectAll("td")
				.data((row, i) => this.columns.map(c => c.fmt(row[c.col]) ))
				.enter()
				.append("td")
				.html(d => d )
				,
			update =>
				update
				.classed("row-selected",
					d => this.status.table_selected_bocks.includes(d.block_no))
				.on("click", d => this.click(d["block_no"]))
				.selectAll("td")
				.data((row, i) => this.columns.map(c => c.fmt(row[c.col]) ))
				.html(d => d )
				,
			exit => exit.remove()
			);

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