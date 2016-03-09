class Gene < ActiveRecord::Base
	belongs_to :gene_set
	belongs_to :feature
	
	def add_field(text)
		arr = text.split(":", 2)
		#puts arr.inspect
		arr[0] = "possition" if arr[0] == "scaffold" or arr[0] == "chromosome"
		arr.unshift("description") if arr.size == 1
		fun = arr[0]+'='
		self.send(fun,arr[1]) if self.respond_to? fun
	end

	def to_s
		name
	end
end
