class PlotContainer{

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

	set height(h){
		this._height = h;
	}

	set width(w){
		this._width = w;
	}

	set offset_x(x){
		this._offset_x = x;
		this.move();
	}

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

	set x(x){
		this._x = x; 
	}

	set y(y){
		this._y = y;
	}
}

window.PlotContainer = PlotContainer;