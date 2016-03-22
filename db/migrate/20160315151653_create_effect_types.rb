class CreateEffectTypes < ActiveRecord::Migration
  def change
    create_table :effect_types do |t|
      t.string :name
      t.string :description

      t.timestamps null: false
    end
  end
end
