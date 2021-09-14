class Region {
  constructor(values) {
    this.assembly = values.assembly;
    this.reference = values.reference;
    this.chromosome = values.chromosome;
    this.start = parseInt(values.start);
    this.end = parseInt(values.end);
    this.orientation = "+";
    if(this.end < this.start){
      this.orientation = "-";
      var tmp = this.end;
      this.end = this.start;
      this.start = tmp;
    }
  }

  get length() {
    return this.end - this.start;
  }

  get id() {
    return (
      this.assembly +
      ":" +
      this.reference +
      ":" +
      this.chromosome +
      ":" +
      this.start +
      ":" +
      this.end
    );
  }

  overlap(other) {
    if (
      other == null ||
      other.reference != this.reference ||
      other.assembly != this.assembly ||
      other.chromosome != this.chromosome
    )
      return false;
    var left = other.start >= this.start && other.start <= this.end;
    var rigth = this.start >= other.start && this.start <= other.end;
    return left || rigth;
  }

  contains(other) {
    if (other.assembly != this.assembly) {
      return false;
    }
    if (other.chromosome != this.chromosome) {
      return false;
    }
    return other.start >= this.start && other.end <= this.end;
  }

  containsAll(others) {
    for (let d of others) {
      if (!this.contains(d)) {
        return false;
      }
    }
    return true;
  }

  region_string() {
    return (
      "" +
      this.assembly +
      ":\t" +
      this.chromosome +
      ":" +
      this.start +
      "-\t" +
      this.end
    );
  }

  inRange(start, end) {
    var left = this.start <= start && this.end >= start;
    var right = this.start <= end && this.end >= end;
    var contained = this.start >= start && this.end <= end;
    return left || right || contained;
  }

  position_in_range(chromosome, position){
    // console.log(this);
    // console.log(chromosome + ":-:" + position)
    let chrom = chromosome == this.chromosome;
    let pos = position >= this.start && position <= this.end 
    // console.log(chrom, pos);
    return  chrom && pos;
  }

  static parse(str){
    var arr = str.match(/(\w+):(\d+)-(\d+)/)
    var reg = new Region({
      chromosome: arr[1],
      start : arr[2],
      end : arr[3], 
      assembly:"",
      reference:""
    })
    return reg;
  }
}
window.Region = Region;
