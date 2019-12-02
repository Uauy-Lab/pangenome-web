class CreateBiotypes < ActiveRecord::Migration[6.0]
  def change
    create_table :biotypes do |t|
      t.string :name, index:true
      t.string :description

      t.timestamps null: false
    end
  end
end
