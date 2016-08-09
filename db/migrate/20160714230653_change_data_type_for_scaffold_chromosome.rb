class ChangeDataTypeForScaffoldChromosome < ActiveRecord::Migration
  def change
    conn = ActiveRecord::Base.connection
    adapter_type = conn.adapter_name.downcase.to_sym
    case adapter_type
    when :mysql
      change_column :scaffolds, :chromosome,  :int
    when :mysql2
      change_column :scaffolds, :chromosome,  :int
    when :sqlite
      change_column :scaffolds, :chromosome,  :int
    when :postgresql
      change_column :scaffolds, :chromosome,  'integer USING CAST (chromosome AS integer)'
    else
      raise NotImplementedError, "Unknown adapter type '#{adapter_type}'"
    end
  end
end
