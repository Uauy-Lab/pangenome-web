class CreateFeatureTypes < ActiveRecord::Migration
  def change
    create_table :feature_types do |t|
      t.string :name, index:true
      t.string :description

      t.timestamps null: false
    end
  end
end
