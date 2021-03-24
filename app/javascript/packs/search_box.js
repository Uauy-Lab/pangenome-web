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
	timeout;
	constructor(div,url,current_status,prefix){
		this.#div = div.append("div")
		this.#url = url;
		this.#status = current_status;
		this.#search_id = `${prefix}-search`;
		this.cache = new Map();
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
			.on("click", this.searchCoordinates);
	}

	get input_text(){
		return this.#input.property("value");
	}

	textInputChange(){
		var self = this;
		if(self.timeout) {
           clearTimeout(self.timeout);
        }
        self.timeout = setTimeout(function() {
        	var search = self.input_text;
        	if(self.cache.has(search)){
        		self.datalist = self.cache.get(search);
        	}else{
        		d3.json(`${self.#url}/${search}.json`).then(
        			(value) => {
        				self.datalist = value;
        				self.cache.set(search, value);
        			}, 
        	        (error) => console.log(`textInputChange ${error}`)
        	    )
        	}
        }, 500);
	}

	set datalist(vals){
		console.log(vals);
		this.#datalist.selectAll("option").data(vals).join(
			enter => enter.append("option").attr("value", d => d)
		)
	}

	searchCoordinates(){
		var search = this.input_text;

	}
}

window.SearchBox = SearchBox;