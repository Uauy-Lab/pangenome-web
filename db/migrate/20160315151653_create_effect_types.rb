class CreateEffectTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :effect_types do |t|
      t.string :name
      t.string :description

      t.timestamps null: false
    end
  end
end
