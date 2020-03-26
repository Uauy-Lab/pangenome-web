class AddIsCannonicalToAssemblies < ActiveRecord::Migration[6.0]
  def change
    add_column :assemblies, :is_cannonical, :boolean, :default => false
  end
end
