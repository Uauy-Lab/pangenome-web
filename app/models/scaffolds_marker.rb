class ScaffoldsMarker < ActiveRecord::Base
  belongs_to :marker
  belongs_to :scaffold
end
