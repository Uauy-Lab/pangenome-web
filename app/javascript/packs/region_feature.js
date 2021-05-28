//http://localhost:3000//wheat/kmer_analysis/kmerGWAS/ref/arinalrfor/sample/flame_kmerGWAS/chr/1A.json
class RegionFeature extends Region {
  constructor(values) {
    super(values);
    this.feature = values["feature"];
    this.search_feature = values["search_feature"];
    this.overlapping_haplotype_blocks = [];
  }

  get has_overlapping_blocks() {
    return this.overlapping_haplotype_blocks > 0;
  }
}

class RegionFeatureSet {
  #url;
  #status;
  #feature_coordinates;
  #highlighted_features;
  #cache;
  #changed;
  #features;
  #last_range;
  #displayed_assemblies;
  #highlight;
  #filter_column;
  constructor(url, status) {
    this.#url = url;
    this.#status = status;
    this.#feature_coordinates = new Map();
    this.#highlighted_features = new Set();
    this.#cache = new Map();
    this.#changed = true;
    this.#features = [];
    this.#last_range = [0, 0];
    this.#displayed_assemblies = [];
    this.#highlight = null;
    this.#filter_column = "id";
  }

  coordiante_url(search) {
    return `${this.#url}/coordinates/${search}.json`;
  }

  async searchCoordinates(search) {
    if (!this.has_feature(search)) {
      await d3
        .json(this.coordiante_url(search))
        .then((value) => this.add_feature(value));
    }
    this.show(search);
  }

  has_feature(feature) {
    return this.#feature_coordinates.has(feature);
  }

  update_feature_ovelap() {
    var hrs = this.#status.haplotype_region_set;
    this.#feature_coordinates.forEach((farr) =>
      farr.forEach(
        (f) => (f.overlapping_haplotype_blocks = hrs.findOverlapingBlocks(f))
      )
    );
  }

  add_feature(feature) {
    var tmp = feature.mappings.map((f) => new RegionFeature(f));
    if (tmp.length == 0) {
      throw " not found";
    }
    this.#feature_coordinates.set(feature.feature, tmp);
    this.update_feature_ovelap();
  }

  get is_empty() {
    return this.#highlighted_features.size == 0;
  }

  show(feature) {
    this.#highlighted_features.add(feature);
    this.#changed = true;
  }

  hide(feature) {
    this.#highlighted_features.delete(feature);
    this.#changed = true;
  }

  set highlight(feature) {
    this.#highlight = feature;
  }

  get highlight() {
    return this.#highlight;
  }

  async autocomplete(search) {
    if (this.#cache.has(search)) {
      return this.#cache.get(search);
    }
    await d3.json(`${this.#url}/autocomplete/${search}.json`).then(
      (value) => this.#cache.set(search, value),
      (error) => console.log(`autocomplete ${error}`)
    );
    return this.#cache.get(search);
  }

  get features() {
    return Array.from(this.#highlighted_features).sort();
  }

  get regions() {
    var range = this.#status.range;
    if (range[0] != this.#last_range[0] || range[1] != this.#last_range[1]) {
      this.#changed = true;
    }
    var da = this.#status.displayed_assemblies;
    var da_ids = this.#status.assemblies;
    if (da_ids.length.length != this.#displayed_assemblies.length) {
      this.#changed |= false;
    }
    if (!this.#changed) {
      da.forEach(
        (v, i) => (this.#changed &= v == this.#displayed_assemblies[i])
      );
    }
    this.#displayed_assemblies = da;
    if (!this.#changed) {
      return this.#features;
    }
    this.#last_range = range;
    var ret = [];
    this.features.forEach((s) =>
      ret.push(
        this.#feature_coordinates
          .get(s)
          .filter((f) => f.inRange(range[0], range[1]) && da.get(f.assembly))
      )
    );
    this.#features = ret.flat();
    this.#changed = true;
    return this.#features;
  }

  overlaps(other_regions) {
    var regions = this.regions;
    if (regions.length == 0) {
      return [];
    }
    return other_regions.filter((rs) =>
      regions.reduce((total, r) => total || rs.overlap(r), false)
    );
  }

  filter(select_ids) {
    // console.log("Filtering");
    // console.log(this.regions);
    var filtered =
      select_ids === undefined || select_ids.length == 0
        ? []
        : this.regions.filter((b) =>
            select_ids.includes(b[this.#filter_column])
          );
    // console.log("DONE F");
    // console.log(filtered);
    return filtered.sort(
      (a, b) => a[this.#filter_column] - b[this.#filter_column]
    );
  }
}

window.RegionFeature = RegionFeature;
window.RegionFeatureSet = RegionFeatureSet;
