class Line < ActiveRecord::Base
	belongs_to :wildtype, :class_name => "Line", :foreign_key => "wildtype_id"
	belongs_to :species
end
