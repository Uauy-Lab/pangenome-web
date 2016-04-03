class Primer < ActiveRecord::Base
  belongs_to :snp
  belongs_to :primer_type
end
