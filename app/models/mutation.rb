class Mutation < ActiveRecord::Base
  belongs_to :scaffold
  belongs_to :chromosome
  belongs_to :library
  belongs_to :gene
  belongs_to :mutation_consequence
end
