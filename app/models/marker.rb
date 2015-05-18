class Marker < ActiveRecord::Base
	has_many :positions
	has_and_belongs_to_many :scaffolds
	has_many :marker_names
	belongs_to :marker_set
end
