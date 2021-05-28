class RegionPlotContainer extends PlotContainer {
  #virtual_plot_height = 0;
  #plot_height = 0;
  #margin = null;
  constructor(svg_g, width, height, current_status, margin) {
    super(svg_g, width, height, 0, 0, current_status);

    this.defs = this.g.append("defs");
    this.clip_path = this.defs.append("svg:clipPath").attr("id", "clip");
    this.clip_rect = this.clip_path
      .append("svg:rect")
      .attr("x", 0)
      .attr("y", 0);
    this.#margin = margin;

    this.svg_plot_elements = this.g
      .append("g")
      .attr(
        "transform",
        "translate(" + this.#margin.left + "," + this.#margin.top + ")"
      )
      .attr("clip-path", "url(#clip)")
      .attr("cursor", "pointer");
  }

  /**
   * @param {{ top: number; right: number; bottom: number; left: number; virtual_plot_height: number; }} m
   */
  set margin(m) {
    this.#margin = m;
  }

  get rendered_height() {
    let rh = this.#virtual_plot_height + this.#margin.top + this.#margin.bottom;
    console.log("RH: " + rh);
    return rh;
  }

  update() {
    let width = this._width - this.#margin.left - this.#margin.right;
    let height = this._height - this.#margin.top - this.#margin.bottom;
    this.plot_width = width;
    this.#plot_height = height;
    this.clip_rect
      .attr("width", this.plot_width)
      .attr("height", this.#plot_height);

    let da = this._current_status.displayed_assemblies;
    let virtual_plot_height = height;
    if (da) {
      let total = 0;
      let vals = da.values();
      for (const d of vals) {
        if (d) total++;
      }
      this.#virtual_plot_height = (total / da.size) * this.#plot_height;
    }
    this._y.rangeRound([0, this.#virtual_plot_height]);
    this._x.rangeRound([0, this.plot_width]);
    this.x_top.rangeRound([0, this.plot_width]);
    this.#margin.rendered_height = this.rendered_height;
  }

  renderPlot() {
    this.haplotype_region_plot = new HaplotypeRegionPlot(
      this.svg_plot_elements,
      this._x,
      this._y,
      this._current_status.color,
      this._current_status
    );
    this.xAxis_g = this.g.append("g");
    this.xAxis_g_top = this.g.append("g");
    this.yAxis_g = this.g.append("g");
    this.assembly_region_plot = new AssemblyRegionPlot(
      this.svg_plot_elements,
      this._x,
      this._y,
      this._current_status
    );

    const chr =
      this._current_status.datasets[this._current_status.current_dataset]
        .chromosomes_lengths;
    let max_val = d3.max(chr, (d) => d.length);
    this._current_status.max_val = max_val;
    this._current_status.end = max_val;
    this._x.domain([0, max_val]);
    this.x_top.domain([0, max_val]);
    this.updateAssembliesDomain();
    this.main_region_axis = new RegionAxis(
      this.xAxis_g,
      this._x,
      this,
      this._current_status
    );
    this.main_region_axis.translate(this.#margin.left, this.#margin.top);
    this.main_region_axis.enable_zoom_brush(max_val);
    this.top_region_axis = new DragAxis(
      this.xAxis_g_top,
      this.x_top,
      this,
      this._current_status
    );
    this.top_region_axis.translate(this.#margin.left, this.#margin.top / 3);
    this.genomes_axis = new GenomesAxis(
      this.yAxis_g,
      this._y,
      this._current_status
    );
    this.genomes_axis.translate(this.#margin.left, this.#margin.top);
    this.genomes_axis.enable_click(this);
  }

  updateAssembliesDomain() {
    const data =
      this._current_status.datasets[this._current_status.current_dataset];
    var asms = data.assemblies;
    if (this._current_status.displayed_assemblies == undefined) {
      this._current_status.displayed_assemblies = asms;
    }
    const displayed = this._current_status.displayed_assemblies;
    this.rendered_assemblies = [];
    displayed.forEach((k, v) => {
      if (k) this.rendered_assemblies.push(v);
    });
    this._y.domain(this.rendered_assemblies);
    this._current_status.color.domain(this.rendered_assemblies);
  }

  refresh_range(duration) {
    console.log("refreshing....");
    this.haplotype_region_plot.refresh_range(duration);
    this.assembly_region_plot.updatePositionLine(duration);
    this.assembly_region_plot.updateCoords(duration);
    this.main_region_axis.refresh_range(duration);
    this.top_region_axis.refresh_range(duration);
  }

  /**
   * @param {Array<Number>} range Start and end positions.
   */
  set region(range) {
    this.haplotype_region_plot.blocks.region = range;
  }
}

window.RegionPlotContainer = RegionPlotContainer;
