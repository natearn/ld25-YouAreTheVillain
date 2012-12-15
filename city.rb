class City
	attr_reader :name
	def initialize name, neighbours
		@name =  name
		if neighbours.any? { |city| city.name = self.name }
			fail "city cannot be a neighbour to itself"
		else
			@links = neighbours
		end
	end
end
