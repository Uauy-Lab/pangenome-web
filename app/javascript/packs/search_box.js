class SearchBox{
	#url;
	#status;
	#search_id;
	#input;
	#datalist;
	#div;
	#button;
	constructor(div,url,current_status,prefix){
		this.#div = div.append("div")
		this.#url = url;
		this.#status = current_status;
		this.#search_id = `${prefix}-search`;
		this.render();
	}

	render(){
		this.#input = this.#div.append("input")
			.attr("type", "search")
			.attr("id", `${this.#search_id}`)
			.attr("list", `${this.#search_id}-list`)
			.on("input", () => this.textInputChange(this));
		this.#datalist = this.#div.append("datalist")
			.attr("id", `${this.#search_id}-list` );
		this.#button  = this.#div.append("button")
			.attr("text");
	}

	get input_text(){
		console.log("Getting bla");
		console.log(this.#input);
		return this.#input.property("value");
	}

	textInputChange(self){
		console.log(self)
		console.log(self.input_text);
	}
}

window.SearchBox = SearchBox;