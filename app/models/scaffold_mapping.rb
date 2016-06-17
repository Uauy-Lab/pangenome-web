class ScaffoldMapping < ActiveRecord::Base
  belongs_to :scaffold
  belongs_to :other_scaffold, :class_name => "Scaffold", :foreign_key => "other_scaffold_id"
end
