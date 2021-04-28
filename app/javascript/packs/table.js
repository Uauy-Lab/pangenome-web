class RegionTable{
	#status;
	#int_fmt =  d3.format(",.5r");
	#columns;
	#div;
	#table_head;
	#body;
	#displayed_blocks;

	constructor(status, columns){
		this.#status  = status;
		this.#columns = columns;
		this.#displayed_blocks = [];
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
		console.log("~~~~~~~~~->");
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

	get displayed_blocks(){
		return this.#displayed_blocks;
	}

	set displayed_blocks(db){
	 	this.#displayed_blocks = db;
	}


	updateTable(to_show, click_id="block_no", id_column="id"){
		this.#body.selectAll("tr")
		.data(to_show, (row)=>row[id_column])
		.join(
			enter =>
				enter.append("tr")
				.classed("row-selected",
					d => this.status.table_selected_bocks.includes(d[click_id]))
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
					d => this.status.table_selected_bocks.includes(d[click_id]))
				.on("click", d => this.click(d[click_id]))
				.selectAll("td")
				.data((row, i) => this.columns.map(c => c.fmt(row[c.col]) ))
				.html(d => d )
				,
			exit => exit.remove()
			);
	}

	displayZoomed(){
		var to_show = this.#displayed_blocks; 
		to_show = to_show.filter(d => d.inRange(this.status.start, this.status.end));
		this.updateTable(to_show);
	}

	showBlocks(blocks, filter_zoom = true){
		//console.log(blocks);
		this.#displayed_blocks = blocks;
		this.#status.table_selected_bocks.length = 0;
		if(filter_zoom){
			this.displayZoomed();
		}else{
			this.updateTable(this.displayed_blocks);
		}
	}


};

window.RegionTable = RegionTable;