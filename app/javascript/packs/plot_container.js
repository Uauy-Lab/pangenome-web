class PlotContainer{
	#x;
	#y;
	constructor(svg_g,width,height,offset_x,offset_y, current_status){
		this._parent      = svg_g;
		this._width  = width;
		this._height = height;
		this._current_status = current_status;
		this._offset_x = offset_x;
		this._offset_y = offset_y;
		this._g = this._parent.append("g");
		this._g.attr("transform", "translate(" + this._offset_x + "," + this._offset_y + ")");
		this._g.classed("plot-container", true);
	}

	/**
	 * @param {number} h
	 */
	set height(h){
		this._height = h;
	}

	/**
	 * @param {number} h
	 */
	set width(w){
		this._width = w;
	}
	/**
	 * @param {number} h
	 */
	set offset_x(x){
		this._offset_x = x;
		this.move();
	}
	/**
	 * @param {number} h
	 */
	set offset_y(y){
		this._offset_y = y;
		this.move();
	}

	move(){
		this._g.attr("transform", "translate(" + this._offset_x + "," + this._offset_y + ")");
	}

	get g(){
		return this._g;
	}
	/**
	 * @param {number} h
	 */
	set x(x){
		this.#x = x; 
	}
	/**
	 * @param {number} h
	 */
	set y(y){
		this.#y = y;
	}

	get x(){
		return this.#x;
	}

	get y(){
		return this.#y;
	}

	get _x(){
		console.warn("_x is depreciated");
		return this.#x;
	}

	get _y(){
		console.warn("_y is depreciated");
		return this.#y;
	}
}

window.PlotContainer = PlotContainer;