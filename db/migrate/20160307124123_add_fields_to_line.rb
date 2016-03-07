class AddFieldsToLine < ActiveRecord::Migration
  def change
    add_column :lines, :mutant, :string,  limit: 1
    add_reference :lines, :species, index: true
    add_foreign_key :lines, :species
  	add_column :lines, :wildtype_id, :integer, index: true
    #belongs_to :image_1, :class_name => "Image"
  end
end
