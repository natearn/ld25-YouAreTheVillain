
require 'rubygame'
require './map.rb'
include Rubygame

max_res = Screen.get_resolution
screen = Screen.open([640,480])
screen.title = "You are the villain!"

clock = Clock.new
clock.calibrate
clock.target_framerate = 30
clock.enable_tick_events

world = Map.new './world.bmp'

world << City.new("Toronto", [30,40])
world << City.new("London", [430,240])
world << City.new("Kingston", [43,340])

world["Toronto"].connect world["London"]
world["Kingston"].connect world["London"]

villain = Villain.new(world["London"])
hero = Hero.new(world["Toronto"])

event_queue = EventQueue.new
event_queue.enable_new_style_events

catch :quit do
	loop do
		delta = clock.tick.seconds
		event_queue.each do |event|
			case event
				when Events::QuitRequested then throw :quit
				when Events::KeyboardEvent then break
			end
		end
		world.draw screen
		hero.draw screen
		villain.draw screen
		screen.flip
	end
end
