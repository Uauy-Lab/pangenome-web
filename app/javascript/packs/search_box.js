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
				console.log(e);
				if (e.key === 'Enter' || e.keyCode === 13) {
					console.log("Enter pressed");
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
	}

	get input_text(){
		return this.#input.property("value");
	}

	textInputChange(){
		//var self = this;
		// if(this.#timeout) {
		// 	clearTimeout(this.#timeout);
		// }
		// var search = this.input_text;
		// this.#timeout = setTimeout( () =>
		//   this.datalist = this.#status.region_feature_set.autocomplete(search)
		//   , 500);
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
		var features = this.#status.region_feature_set.features;
		// console.log("Updatign box!")
		// console.log(features);
		// console.log(this.#status.region_feature_set.highlight);
		this.#features_div.selectAll(".feature-tag")
		.data(features)
		.join(
			enter => enter.append("button")
				.attr("class", "feature-tag")
				.text(d => d)
				.on("click", d=> this.removeFeature(d))
				.on("mouseover", d => this.highlightFeature(d))
				.on("mouseout", d => this.highlightFeature("")),
			update => update
				.text(d => d)
				.style("background-color", d =>
					d == this.#status.region_feature_set.highlight ? "black":"darkred" ) ,

			exit   => exit.remove()
			)
	}

	removeFeature(feature){
		console.log(`Removing ${feature}`)
		this.#status.region_feature_set.hide(feature);
		this.#status.target.refresh(500);
	}

	highlightFeature(feature){
		this.#status.region_feature_set.highlight = feature;
		this.#status.target.refresh(500);
	}

}

window.SearchBox = SearchBox;