class AddReferenceAssemblyToHaplotypeBlock < ActiveRecord::Migration[6.0]
  def change
    add_column :haplotype_blocks, :reference_assembly, :bigint
    add_foreign_key :haplotype_blocks, :assemblies, column: :reference_assembly
  end

end
