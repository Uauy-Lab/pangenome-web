class GenomesAxis extends Axis {
  constructor(svg_g, scale, status) {
    super(svg_g, scale, d3.axisLeft, status);
    this.axis_g.attr("class", "y axis");
    this.background_rect.attr("class", "y-rect");
    this.highlight_rect = svg_g.append("rect").attr("class", "y-select");
    this.svg_g.node().classList.add("pointer");
  }

  translate(x, y) {
    super.translate(x, y);
    this.update_rect();
  }

  update_rect(asm) {
    var h = 0;
    var y = 0;
    if (asm) {
      h = this.scale.step();
      y = this.scale(asm);
    }
    this.highlight_rect
      .attr("x", -this.offset_x)
      .attr("y", y)
      .attr("width", this.offset_x)
      .attr("height", h);
  }

  click(coords) {
    if (coords.x >= 0 || this.status.lock) return;
    var asm = coords.asm;
    if (this.status.assembly == asm) {
      asm = undefined;
      //this.status.selected_blocks.length = 0;
      this.status.assembly = undefined;
      //this.status.clearHighlight();
    } else {
      blocks = this.status.setBaseAssembly(asm);
      this.status.frozen = false;
    }
    this.update_rect(asm);
    this.status.assembly = asm;
  }

  mouseover() {
    //if(!this.event_overlap()) return;
    //	var asm = this.asmUnderMouse();
  }

  enable_click(target) {
    this.target = target;
    //this.svg_g.on("click", this.click.bind(this));
  }

  translateRect() {
    this.background_rect
      .attr("x", -this.offset_x)
      .attr("y", 0)
      .attr("width", this.offset_x)
      .attr("height", this.scale.range()[1]);
  }

  refresh_range(duration) {
    this.axis_g.transition().duration(duration).call(d3.axisLeft(this.scale));
  }
}

window.GenomesAxis = GenomesAxis;
