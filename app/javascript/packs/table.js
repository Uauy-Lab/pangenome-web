class Table{
	#status;
	#int_fmt =  d3.format(",.5r");
	#columns;
	#div;
	#table_head;
	#body;
	constructor(status, columns){
		this.#status  = status;
		this.#columns = columns;
	}

	get columns(){
		return this.#columns;
	}


	get status(){
		return this.#status;
	}

	click(data_id){
		return;
	}

	get int_fmt(){
		return this.#int_fmt;
	}

	renderTable(div){
		this.#div = div;

		this.#table_head = this.#div.append("div").classed("tbl-header", true).append("table");
		this.#table_head.append('thead').append('tr')
   		.selectAll('th')
   		.data(this.columns).enter()
   		.append('th')
   		.text(d => d.header);
   		let table_body = this.#div.append("div").classed("tbl-content", true).append("table")
   		this.#body = table_body.append("tbody");
	}

	get body(){
		return this.#body;
	}

	updateTable(to_show, click_id="block_no"){
		this.#body.selectAll("tr")
		.data(to_show)
		.join(
			enter =>
				enter.append("tr")
				.classed("row-selected",
					d => this.status.table_selected_bocks.includes(d.block_no))
				.on("click", d => this.click(d[click_id]))
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
				.on("click", d => this.click(d[click_id]))
				.selectAll("td")
				.data((row, i) => this.columns.map(c => c.fmt(row[c.col]) ))
				.html(d => d )
				,
			exit => exit.remove()
			);
	}


};

window.Table = Table;