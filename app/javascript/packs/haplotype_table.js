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
		]
	}

	renderTable(div){
		this.div = div;
		this.table_head = this.div.append("table");
		this.table_head.classed("tbl-header", true);
		this.head = this.table_head.append('thead').append('tr')
   		.selectAll('th')
   		.data(this.columns).enter()
   		.append('th')
   		.text(d => d.header);
   		this.table_body = this.div.append("table")
   		this.table_body.classed("tbl-content", true);
   		this.body = this.table_body.append("tbody")

	}

	showBlocks(blocks){
		console.log(blocks);
		var self = this;
		this.body.selectAll("tr")
		.data(blocks)
		.join(
			enter =>
				enter.append("tr")
				.selectAll("td")
				.data((row, i) => {
					console.log(row);
					console.log(i);
					return self.columns.map(c => c.fmt(row[c.col]) );
				})
				.enter()
				.append("td")
				.html(d => d )
			);
	}
}

window.HaplotypeTable = HaplotypeTable;