import "./event_coordinates";

class CurrentStatus {
  #current_dataset;
  #app_status;
  #assembly;
  #selected_assembly = undefined;
  #selected_blocks = [];
  #highlighted_blocks = [];
  constructor(target) {
    this.start = 0;
    this.end = 0;
    this.position = -1;
    this.max_val = 0;
    this.roundTo = 10000;
    this.transitions = 0;
    this.loaded = false;
    this.target = target;
    this.updating = false;
    this.lock = false;
    this.frozen = false;
    this.haplotype_table_selected_bocks = [];
    this.current_coord_mapping = undefined;
    this.assemblies_reference = [];
    this._displayed_assemblies = undefined;
    this.displayed_samples = new Set();
    this.plot_width = 0;
    this.plot_height = 0;
    this.coordinates = new EventCoordinates();
    this.datasets = null;
    this.#current_dataset = null;
    this.region_feature_set = null;
    this.#app_status = null;
  }

  round(x) {
    return Math.round(this.target.x.invert(x) / this.roundTo) * this.roundTo;
  }
  set app_status(as) {
    this.#app_status = as;
  }
  set current_dataset(current_dataset) {
    this.#current_dataset = current_dataset;
  }

  get current_dataset() {
    return this.#current_dataset;
  }

  get x() {
    return this.target.x;
  }

  get y_scores() {
    return this.target.y_scores;
  }

  get y_scores_domain() {
    return this.target.y_scores.domain();
  }

  get y_scores_full() {
    return this.target.y_scores_full;
  }

  get color_axis() {
    return this.target.color;
  }

  get assembly() {
    if (this.#selected_assembly !== undefined) {
      return this.#selected_assembly;
    }
    return this.#assembly;
  }

  get coordinate_mapping() {
    return this.target.coord_mapping[this.current_coord_mapping];
  }

  set assembly(asm) {
    this.#assembly = asm;
  }

  set selected_assembly(asm) {
    this.#selected_assembly = asm;
  }

  get margin() {
    return this.target.margin;
  }

  get stop_interactions() {
    return this.lock || this.frozen || this.transitions;
  }

  get blocks_for_table() {
    // console.log("Getting regions for table");
    // console.log(this.haplotype_region_set);
    var regs = this.haplotype_region_set.filter(this.selected_blocks);
    var all_blocks = this.haplotype_region_set.data;
    return this.has_selected_blocks ? regs : all_blocks;
  }

  get has_selected_blocks() {
    return this.selected_blocks.length > 0;
  }

  set highlighted_blocks(hb) {
    this.#highlighted_blocks = hb;
  }

  get highlighted_blocks() {
    let hb = this.haplotype_table_selected_bocks;
    // console.log("Table highlighted blocks...");
    // console.log(hb);
    hb = hb.length == 0 ? this.#highlighted_blocks : hb;
    hb = hb ? hb : [];
    return hb;
  }

  get highligted_for_tables() {
    //let rfs = this.region_feature_set.regions;
    let hrs = this.haplotype_region_set;
    let ht = this.target.hap_table;
    let ft = this.target.feat_table;

    console.log("Calculating highlighted and selected blocks");
    console.log(ht.selected_regions);
    console.log(ft.selected_regions);
    let overlapping = hrs.findAllOverlaplingBlocks(ft.selected_regions);
    console.log(overlapping);
    return ht;
  }

  start_transition() {
    this.transitions++;
    this.target.updateStatus("...", true);
  }

  end_transition() {
    if (--this.transitions === 0 && this.updating == false) {
      this.target.updateStatus("", false);
    }
  }

  toggle_frozen() {
    this.frozen = !this.frozen;
  }

  /**
   * This will store only the block_nos that are going to be displayed.
   * Blocks that are to be selected in the plot and displayed on the table
   * @param block_nos
   */
  set selected_blocks(block_nos) {
    this.#selected_blocks = block_nos; //.map(b => b.block_no);
  }

  get selected_blocks() {
    return this.#selected_blocks;
  }

  update_table_and_highlights() {
    this.clear_blocks();
    let rfs = this.region_feature_set.regions;
    let hrs = this.haplotype_region_set;
    let to_display = this.highligted_for_tables;
    console.log(to_display);

    this.selected_blocks = hrs
      .findAllOverlaplingBlocks(rfs)
      .map((b) => b.block_no);

    console.log("This should be the selected blocks from the left table:");
    console.log(this.table_selected_bocks);
    var blocks = this.blocks_for_table;
    this.highlighted_blocks = [...new Set(blocks.map((b) => b.block_no))];
    if (this.table_selected_bocks && this.table_selected_bocks.length > 0) {
      this.highlighted_blocks = this.highlighted_blocks.filter((b) =>
        this.table_selected_bocks.includes(b)
      );
    }

    if (this.target.hap_table) {
      this.target.hap_table.showBlocks(blocks);
    }
    this.target.refresh(500);
    this.frozen = this.#highlighted_blocks.length > 0;
  }

  async add_feature(feature) {
    try {
      await this.region_feature_set.searchCoordinates(feature);
      this.region_feature_set.show(feature);
    } catch (e) {
      this.error(feature + e);
      console.trace(e);
    }
    this.update_table_and_highlights();
  }

  remove_feature(feature) {
    this.region_feature_set.hide(feature);
    this.update_table_and_highlights();
  }

  highlight_feature(feature) {
    this.region_feature_set.highlight = feature;
  }

  get mapped_coords() {
    var ret = this._mapped_coords;
    if (this._displayed_assemblies && ret && ret.length > 0) {
      ret = ret.filter((r) => this._displayed_assemblies.get(r.assembly));
    } else {
      ret = [];
    }
    return ret;
  }

  set display_coords(coords) {
    if (coords) {
      if (coords.asm && coords.x > 0 && coords.blocks.length > 0) {
        this.#selected_assembly = coords.asm;
      } else {
        this.#selected_assembly = undefined;
      }
      this.position = this.target.x.invert(coords.x);
      this._mapped_coords = this.coordinate_mapping;
      this._mapped_coords = this._mapped_coords.regions_under(coords, this);
    }
  }

  set displayed_assemblies(asm) {
    if (asm == undefined) {
      this._displayed_assemblies = undefined;
      return;
    }
    this._displayed_assemblies = new Map();
    asm.forEach((a) => this._displayed_assemblies.set(a, true));
  }

  get displayed_assemblies() {
    return this._displayed_assemblies;
  }

  get assemblies() {
    var ret = [];
    this._displayed_assemblies.forEach((v, k) => {
      if (v) {
        ret.push(k);
      }
    });
    return ret.sort();
  }

  setRange(range) {
    this.target.setRange(range);
  }

  setScoreRange(range) {
    this.target.setScoreRange(range);
  }

  clearHighlight() {
    this.target.clearHighlight();
  }

  setBaseAssembly(asm) {
    this.target.setBaseAssembly(asm);
  }

  get range() {
    return [this.start, this.end];
  }

  error(msg) {
    if (this.#app_status) {
      this.#app_status.alert_error(msg);
    } else {
      console.log("Error: " + msg);
    }
  }

  /**
   * Returns the haplotype blocks based on the current datasets
   * @return {HaplotypeRegionSet} A HaplotypeRegionSet object.
   */
  get haplotype_region_set() {
    return this.datasets[this.current_dataset];
  }

  clear_blocks() {
    this.haplotype_table_selected_bocks.length = 0;
  }
}

window.CurrentStatus = CurrentStatus;
