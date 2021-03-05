class Library < ActiveRecord::Base
  belongs_to :line, :autosave => true

  def self.find_by_line(library, line:"CS",species:"wheat")
  	species  = Species.find_species(species)
  	line = Line.find_or_create_by(name: line, species:species)
  	line.save!
  	lib = Library.find_or_create_by(name:library, line: line)
  	lib
  end
end
