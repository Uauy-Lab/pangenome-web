//import $ from "jquery";
//import "jquery-ui"
//require("easy-autocomplete")

class SearchBox{
	#url;
	#status;
	#search_id;
	#input;
	#datalist;
	#div;
	#button;
	#timeout;
	constructor(div,url,current_status,prefix){
		this.#div = div.append("div")
		this.#url = url;
		this.#status = current_status;
		this.#search_id = `${prefix}-search`;
		this.render();
	}

	render(){
		this.#input = this.#div.append("input")
			.attr("type", "text")
			.attr("id", `${this.#search_id}`)
			.attr("list", `${this.#search_id}-list`)
			.attr("autocomplete", "all")
			.on("input", () => this.textInputChange());
		this.#datalist = this.#div.append("datalist")
		  	.attr("id", `${this.#search_id}-list` );
		this.#button  = this.#div.append("input")
			.attr("type", "button")
			.attr("value", "Search")
			.on("click", ()  => this.searchCoordinates() );
	}

	get input_text(){
		return this.#input.property("value");
	}

	textInputChange(){
		//var self = this;
		if(this.#timeout) {
			clearTimeout(this.#timeout);
		}
		var search = this.input_text;
		this.#timeout = setTimeout( () =>
		  this.datalist = this.#status.region_feature_set.autocomplete(search)
		  , 500);
	}

	set datalist(vals){
		this.#datalist.selectAll("option").data(vals).join(
			enter => enter.append("option").attr("value", d => d)
		)
	}

	async searchCoordinates(){
		var self = this;
		var search = this.input_text;
		await this.#status.region_feature_set.searchCoordinates(search);
		this.#status.region_feature_set.highlight_feature(search);
		this.#status.target.refresh(500);
	}

	


}

window.SearchBox = SearchBox;