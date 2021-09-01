import  * as d3 from 'd3'
//import $ from "jquery";
import jquery from "jquery";
import "./plot_container"
import "./axis"
import "./region_axis"
import "./genomes_axis"
import "./region_axis";
import "./region_score_axis";
import "./region";
import "./table";
import "./haplotype_region";
import "./haplotype_region_set";
import "./haplotype_region_plot";
import "./haplotype_drag_axis";
import "./haplotype_table";
import "./event_coordinates";
import "./current_status";
import "./assembly_region_plot";
import "./assembly_region_set";
import "./region_score_container";
import "./region_score";
import "./region_score_set";
import "./region_score_plot_container";
import "./region_score_plot";
import "./search_box";
import "./region_feature";
import "./region_plot_container";
import "./feature_table";
import "./mapping_coordinates_region_set"


class MappingCoordinatesPlot{
	#mapping_region_set;
	constructor(options){
		this.setDefaultOptions();
		jquery.extend(this.opt, options);
		//path="/Wheat/pangenome_mapping/5/chr/chr2B__chi/start/685850001/end/686150000.csv"
		this.#mapping_region_set = new MappingRegionSet(options);
		this.#mapping_region_set.readData();
	}

	setDefaultOptions (){
		this.opt = {
			'target': 'haplotype_plot', 
			'width': 800, 
			'height':500
		}
	}
};

window.MappingCoordinatesPlot = MappingCoordinatesPlot;