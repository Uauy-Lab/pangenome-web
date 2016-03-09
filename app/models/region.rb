class Region < ActiveRecord::Base
  belongs_to :scaffold

  def to_s
  	scaffold.name + ":" + self.start.to_s + "-" + self.end.to_s
  end
end
