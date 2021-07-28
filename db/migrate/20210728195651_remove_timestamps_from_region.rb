class RemoveTimestampsFromRegion < ActiveRecord::Migration[6.1]
  def change
    remove_column :regions, :created_at, :string
    remove_column :regions, :updated_at, :string
  end
end
