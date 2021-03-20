import $ from "jquery";
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
		this.render();
	}

	render(){
		this.#input = this.#div.append("input")
			.attr("type", "search")
			.attr("id", `${this.#search_id}`)
			.attr("list", `${this.#search_id}-list`)
			.attr("autocomplete", "all")
			.on("input", () => this.textInputChange());



		 // $( `#${this.#search_id}` ).autocomplete({
   //    source: this.#url,
   //    minLength: 3,
   //    select: function( event, ui ) {
   //      log( "Selected: " + ui.item.value + " aka " + ui.item.id );
   //    }
   //  });
		this.#datalist = this.#div.append("datalist")
		  	.attr("id", `${this.#search_id}-list` );
		this.#button  = this.#div.append("button")
			.attr("text");
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
        	d3.json(`${self.#url}/${search}.json`).then(
        	 	(value) => self.datalist = value, 
        	 	(error) => console.log(`textInputChange ${error}`)
        	 )
        }, 500);
		
		

	}

	set datalist(vals){
		console.log("datalist");
		console.log(vals);

		//this.#datalist.selectAll("*").remove();
		this.#datalist.selectAll("option").data(vals).join(
			enter => enter.append("option").attr("value", d => d)
		)
		//this.#datalist.style("display" , 'block');
	}
}

window.SearchBox = SearchBox;