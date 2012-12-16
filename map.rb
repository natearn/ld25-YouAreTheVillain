
require 'rubygame'
Rubygame::TTF.setup
$name_font = Rubygame::TTF.new "Share_Tech/ShareTech-Regular.ttf", 18
$funds_font = Rubygame::TTF.new "Share_Tech/ShareTech-Regular.ttf", 14


class Map
	include Rubygame::Sprites::Sprite

	def initialize cities = {}
		#@image = Rubygame::Surface.load file
		@image = Rubygame::Surface.new([640,480]).fill(:blue)
		@rect = @image.make_rect
		@cities = cities
	end

	def draw surface
		super(surface)
		@cities.each_value { |city|
			city.neighbours.each { |n|
				surface.draw_line_a(city.position, n.position, :navy)
			}
		}
		@cities.each_value { |city|
			city.draw surface
		}
	end

	def update
		@cities.each_value { |city|
			return true if city.update
		}
		return false
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
	attr_reader :name, :position, :radius, :neighbours, :priority, :last_checked

	def initialize name, position, radius = 32
		@name = name
		@position = position
		@funds = rand(1000) + 500
		@radius = radius
		@neighbours = []
		@name_label = $name_font.render_utf8(name,true,:yellow)
		@priority = 1
		@last_checked = 1
	end

	def update
		@funds += rand(200) + 50
		@lab += 1 if @lab
		@silo -= 1 if @silo
		@priority += 1 if @priority <= @neighbours.size
		@last_checked += 1
		return (@silo && @silo <= 0)
	end

	def rob_bank
		loss = @funds / 2
		@funds -= loss
		@priority = 0
		return loss
	end

	def build_lab funds
		return false if @lab
		return false if funds < 2000
		#build the lab
		@lab = -3
		return funds - 2000
	end

	def build_silo funds
		return false if @silo
		return false unless @lab && @lab >= 10
		return false if funds < 10000
		@lab -= 10
		@silo = 10
	end

	def investigate
		@silo = nil
		@lab = nil
		@last_checked = 0
		return $villain.city == self
	end

	def connect city
		fail "cannot connect to nil" if city.nil?
		fail "cannot connect to self" if city.name == self.name
		unless self.is_connected? city
			@neighbours << city 
			@priority = @neighbours.size
			city.connect self # connections must be mutual
		end
	end

	def is_connected? city
		return @neighbours.include? city
	end

	def draw surface
		surface.draw_circle_s(@position, @radius, :green)
		rect = @name_label.make_rect
		pt = @position.dup
		pt[1] += @radius
		rect.midtop = pt
		@name_label.blit surface, rect
		@funds_label = $funds_font.render_utf8("$#{@funds}",true,:green)
		pt = rect.midbottom
		rect = @funds_label.make_rect
		rect.midtop = pt
		@funds_label.blit surface, rect
		if @lab
			@@lab_image ||= Rubygame::Surface.new([8,8]).fill(:white)
			rect = @@lab_image.make_rect
			rect.center = @position
			rect[0] += @radius / 2
			@@lab_image.blit surface, rect
			@lab_label = $funds_font.render_utf8(@lab.to_s,true,:white)
			pt = rect.midbottom
			rect = @lab_label.make_rect
			rect.midtop = pt
			@lab_label.blit surface, rect
		end
		if @silo
			@@silo_image ||= Rubygame::Surface.new([8,8]).fill(:brown)
			rect = @@silo_image.make_rect
			rect.center = @position
			rect[0] -= @radius / 2
			@@silo_image.blit surface, rect
			@silo_label = $funds_font.render_utf8(@silo.to_s,true,:red)
			pt = rect.midbottom
			rect = @silo_label.make_rect
			rect.midtop = pt
			@silo_label.blit surface, rect
		end
	end

	# cities can have stuff, including players (that might need to be drawn)
end

class Villain
	attr_reader :city

	def initialize city
		@city = city
		@target_index = 0
		@funds = 1000
	end

	def draw surface
		pt = @city.position.dup
		pt[1] += (@city.radius / 2)
		surface.draw_circle_s(pt,4,:yellow)
		# draw target
		pos = self.target.position
		rad = self.target.radius * 1.25
		surface.draw_circle_a(pos,rad,:yellow)
		# draw funds
		@funds_label = $name_font.render_utf8("$#{@funds}",true,:yellow)
		rect = @funds_label.make_rect
		rect.bottomleft = surface.make_rect.bottomleft
		@funds_label.blit surface, rect
	end

	def move
		@city = self.target
		@target_index = 0
	end

	def target 
		@city.neighbours[@target_index]
	end

	def move_target num = 0
		@target_index = (@target_index + num) % @city.neighbours.size
	end

	def handle event
		fail "wrong type" unless event.is_a? Rubygame::Events::KeyboardEvent
		return if event.is_a? Rubygame::Events::KeyReleased
		case event.key
			when :right, :down
				self.move_target 1
				return false
			when :left, :up
				self.move_target -1
				return false
			when :space, :return
				self.move
				return true
			when :r
				@funds += @city.rob_bank
				return true
			when :l
				change = @city.build_lab(@funds)
				if change
					@funds = change
					return true
				else
					return false
				end
			when :s
				change = @city.build_silo(@funds)
				if change
					@funds = change
					return true
				else
					return false
				end
		end
	end
end

class Hero

	def initialize city
		@city = city
	end

	def action
		# common sense move
		return @city.investigate if @city.priority == 1

		# sort by priority
		options = @city.neighbours.sort { |a,b|
			a.priority <=> b.priority
		}

		#randomly choose a move weighted on priority
			# (1 / priority) chance of move
			# priority caps at number of neighbours + 1
		options.each { |town|
			if rand(town.priority) == 0
				@city = town
				return false
			end
		}

		# don't bother re-investigating cities without priority
		if @city.last_checked < 2
			@city = options.first
			return false
		end

		# investigate
		return @city.investigate
	end

	def draw surface
		pt = @city.position.dup
		pt[1] -= (@city.radius / 2)
		surface.draw_circle_s(pt,4,:red)
	end
end
