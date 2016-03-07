class DeletedScaffold < ActiveRecord::Base
  belongs_to :scaffold
  belongs_to :library
end
