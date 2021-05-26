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
	#outerdiv;
	#features_div;

	constructor(div,url,current_status,prefix){
		this.#outerdiv = div.append("div")
		.style("display", "inline-block")
		this.#url = url;
		this.#status = current_status;
		this.#search_id = `${prefix}-search`;
		this.render();
	}

	render(){
		this.#div = this.#outerdiv.append("div")
			.style("display", "inline-block")
		this.#input = this.#div.append("input")
			.attr("type", "text")
			.attr("id", `${this.#search_id}`)
			.attr("list", `${this.#search_id}-list`)
			.attr("autocomplete", "all")
			.on("keyup", () => { 
				var e = d3.event;
				if (e.key === 'Enter' || e.keyCode === 13) {
					this.searchCoordinates();
			}})
			.on("input", () => this.textInputChange());
		this.#datalist = this.#div.append("datalist")
		  	.attr("id", `${this.#search_id}-list` );
		this.#button  = this.#div.append("input")
			.attr("type", "button")
			.attr("value", "Search")
			.on("click", ()  => this.searchCoordinates() );
		this.#features_div = this.#outerdiv.append("div")
			.style("display", "inline-block")
		this.updateDisplay();
	}

	get input_text(){
		return this.#input.property("value");
	}

	textInputChange(){
		
	}

	set datalist(vals){
		this.#datalist.selectAll("option").data(vals).join(
			enter => enter.append("option").attr("value", d => d)
		)
	}

	searchCoordinates(){
		var search = this.input_text;
		this.#status.add_feature(search);
		this.#input.property("value", "");
	}



	updateDisplay(){
		let status = this.#status; 
		let features = status.region_feature_set.features;
		this.#features_div.selectAll(".feature-tag")
		.data(features)
		.join(
			enter => enter.append("button")
				.classed("feature-tag", true)
				.text(d => d)
				.classed("feature-no-highlight", true)
				.on("click", d=> status.remove_feature(d))
				.on("mouseover", d => status.highlight_feature(d))
				.on("mouseout", d => status.highlight_feature("")),
			update => update
				.text(d => d)
				.classed("feature-no-highlight", 
					d => d != this.#status.region_feature_set.highlight)
				.classed("feature-highlight", 
					d => d == this.#status.region_feature_set.highlight)
				,
			exit   => exit.remove()
			)
	}

}

window.SearchBox = SearchBox;
