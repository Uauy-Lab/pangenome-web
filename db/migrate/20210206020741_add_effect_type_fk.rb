class AddEffectTypeFk < ActiveRecord::Migration[6.1]
  def change
  	add_foreign_key :effects, :effect_types
  end
end
