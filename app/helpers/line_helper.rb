module LineHelper
	def self.find_library(name, create:true)
		@@libraries = Hash.new unless @@libraries
		return @@libraries[name] if @@libraries[name]
		arr = name.split("_")
		ret = nil
		arr.each do |e|  
		ret = Library.find_by(name: e)
			@@libraries[name] = ret
			return ret if ret
		end
		puts  "Library: #{name} not found!"
		ret = Library.find_or_create_by(name: arr[0])
		@@libraries[name] = ret
		ret
	end


	def self.find_line(name)
		@@lines = Hash.new unless @@lines
		return @@lines[name] if @@lines[name]
		arr = name.split("_")
		ret = nil
		arr.each do |e|  
			ret = Line.find_by(name: e)
			@@lines[name] = ret
			return ret if ret
		end
		puts  "Library: #{name} not found!"
		ret = Line.find_or_create_by(name: arr[0])
		@@lines[name] = ret
		ret
	end

	
end