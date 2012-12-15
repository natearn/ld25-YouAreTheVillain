
require 'rubygame'

class Map
	include Rubygame::Sprites::Sprite

	def initialize file, cities = {}
		@image = Rubygame::Surface.load file
		@rect = @image.make_rect
		@cities = cities
	end

	def draw surface
		super(surface)
		@cities.each_value { |city|
			city.draw surface
		}
	end

	def [] name
		@cities[name]
	end

	def []= name, city
		@cities[name] = city
	end

	def << city
		@cities[city.name] = city
	end
end

class City
	include Rubygame::Sprites::Sprite

	attr_reader :name, :rect, :neighbours

	def image
		@@image ||= Rubygame::Surface.load('./city.bmp')
	end

	def initialize name, position
		@name = name
		@rect = self.image.make_rect
		self.rect.topleft = position
		@neighbours = []
	end

	def connect city
		fail "cannot connect to nil" if city.nil?
		fail "cannot connect to self" if city.name == self.name
		unless self.is_connected? city
			@neighbours << city 
			city.connect self # connections must be mutual
		end
	end

	def is_connected? city
		return @neighbours.include? city
	end

	def draw surface
		@neighbours.each { |city|
			surface.draw_line_a(self.rect.center, city.rect.center, :brown)
		}
		super(surface)
	end

	# cities can have stuff, including players (that might need to be drawn)
end

class Hero
	include Rubygame::Sprites::Sprite

	def initialize city
		@location = city
	end

	def image
		@@image ||= Rubygame::Surface.load('./hero.bmp')
	end

	def rect
		base = self.image.make_rect
		base.center = @location.rect.center
		base.move(0, (@location.rect.height / 4))
	end
end

class Villain
	include Rubygame::Sprites::Sprite

	def initialize city
		@location = city
	end

	def image
		@@image ||= Rubygame::Surface.load('./villain.bmp')
	end

	def rect
		base = self.image.make_rect
		base.center = @location.rect.center
		base.move(0, ((@location.rect.height / 4) * -1))
	end

	def move city
		if @location.is_connected? city
			@location = city
		end
	end

end
