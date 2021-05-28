class RegionTable {
  /** @type {CurrentStatus} */
  #status;
  #int_fmt = d3.format(",.5r");
  #columns;
  #div;
  #table_head;
  #body;
  #displayed_blocks;
  #click_id;
  #id_column;
  #selected_ids;
  /** @type {RegionSet} */
  #region_set;
  #buttons;
  #save_btn;

  constructor(
    status,
    columns,
    region_set,
    click_id = "block_no",
    id_column = "id"
  ) {
    this.#status = status;
    this.#columns = columns;
    this.#displayed_blocks = [];
    this.#click_id = click_id;
    this.#id_column = id_column;
    this.#selected_ids = [];
    this.#region_set = region_set;
  }

  get columns() {
    return this.#columns;
  }

  /**
   * Returns the status attached to the table
   * @return {CurrentStatus} .
   */
  get status() {
    return this.#status;
  }

  get selected() {
    return this.#selected_ids;
  }

  set region_set(rs) {
    this.#region_set = rs;
    this.updateTable(rs);
  }

  get region_set() {
    return this.#region_set;
  }

  click(data_id) {
    if (!this.#selected_ids.includes(data_id)) {
      this.#selected_ids.push(data_id);
    } else {
      this.#selected_ids = this.#selected_ids.filter(
        (item) => item !== data_id
      );
    }
    this.body
      .selectAll("tr")
      .classed("row-selected", (d) =>
        this.#selected_ids.includes(d[this.#click_id])
      )
      .classed(
        "row-non-selected",
        (d) => !this.#selected_ids.includes(d[this.#click_id])
      );
    return;
  }

  get int_fmt() {
    return this.#int_fmt;
  }

  renderButton(div, class_ = "btn", text = "Save") {
    console.log(div);
    var btn = div
      .append("input")
      .attr("id", id)
      .attr("type", "button")
      .attr("value", text);
    return btn;
  }

  renderTable(div) {
    this.#div = div;
    this.#buttons = this.#div.append("div");
    this.#buttons.classed("tbl-buttons", true);
    this.#save_btn = this.renderButton(
      this.#buttons,
      "save-button",
      (text = "Save")
    );
    this.#table_head = this.#div
      .append("div")
      .classed("tbl-header", true)
      .append("table");
    this.#table_head
      .append("thead")
      .append("tr")
      .selectAll("th")
      .data(this.columns)
      .enter()
      .append("th")
      .classed("tbl-header", true)
      .style("min-width", (d) => d.width)
      .text((d) => d.header);
    let table_body = this.#div
      .append("div")
      .classed("tbl-content", true)
      .append("table");
    this.#body = table_body.append("tbody");
  }

  get body() {
    return this.#body;
  }

  get displayed_blocks() {
    return this.#displayed_blocks;
  }

  set displayed_blocks(db) {
    this.#displayed_blocks = db;
  }

  column_width(i) {
    return this.#columns[i].width;
  }

  updateTable(to_show) {
    let click_id = this.#click_id;
    let id_column = this.#id_column;
    this.#body
      .selectAll("tr")
      .data(to_show, (row) => row[id_column])
      .join(
        (enter) =>
          enter
            .append("tr")
            .classed("row-selected", (d) =>
              this.#selected_ids.includes(d[click_id])
            )
            .classed("tbl-content", true)
            .on("click", (d) => this.click(d[click_id]))
            .selectAll("td")
            .data((row, i) => this.columns.map((c) => c.fmt(row[c.col])))
            .enter()
            .append("td")
            .style("min-width", (c, i) => this.column_width(i))
            .html((d) => d),
        (update) =>
          update
            .classed("row-selected", (d) =>
              this.#selected_ids.includes(d[click_id])
            )
            .classed("tbl-content", true)
            .on("click", (d) => this.click(d[click_id]))
            .selectAll("td")
            .data((row, i) => this.columns.map((c) => c.fmt(row[c.col])))
            .html((d) => d),
        (exit) => exit.remove()
      );
  }

  displayZoomed() {
    var to_show = this.displayed_blocks;
    to_show = to_show.filter((d) =>
      d.inRange(this.status.start, this.status.end)
    );
    this.updateTable(to_show);
  }

  /**
   * The Blocks that will be rendered in the table
   *
   * @param {[Region]} blocks
   * @param {boolean} filter_zoom
   */
  showBlocks(blocks, filter_zoom = true) {
    // console.log("Show blocks!");
    // console.log(filter_zoom);
    //console.log(blocks);
    this.#displayed_blocks = blocks;
    this.#status.clear_blocks();
    if (filter_zoom) {
      this.displayZoomed();
    } else {
      this.updateTable(this.displayed_blocks);
    }
  }
}

window.RegionTable = RegionTable;
