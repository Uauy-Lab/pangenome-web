class MappingCoordinatePlotContainer extends PlotContainer{
	#g_axis;
	#g_mapping;
	#g_mapped_blocks;
	constructor(svg_g,width,height,offset_x,offset_y, current_status){
		super(svg_g,width,height,offset_x,offset_y, current_status);


	}

}
window.MappingCoordinatePlotContainer = MappingCoordinatePlotContainer;