
require 'rubygame'
require './map'
include Rubygame

max_res = Screen.get_resolution
$screen = Screen.open([640,480])
$screen.title = "You are the villain!"

clock = Clock.new
clock.calibrate
clock.target_framerate = 30
clock.enable_tick_events

world = Map.new

world << City.new("London", [30,40])
world << City.new("Toronto", [220,220])
world << City.new("Berlin", [250,360])
world << City.new("Kingston", [43,340])
world << City.new("Ottawa", [350,140])
world << City.new("Montreal", [500,20])

world["Toronto"].connect world["London"]
world["Kingston"].connect world["London"]
world["Toronto"].connect world["Ottawa"]
world["Montreal"].connect world["Ottawa"]
world["Toronto"].connect world["Berlin"]
world["Kingston"].connect world["Berlin"]

$villain = Villain.new(world["London"])
$hero = Hero.new(world["Toronto"])

event_queue = EventQueue.new
event_queue.enable_new_style_events

def gameover surface, message
	font = Rubygame::TTF.new "Share_Tech/ShareTech-Regular.ttf", 96
	label = font.render_utf8(message,true,:black)
	rect = label.make_rect
	rect.center = surface.make_rect.center
	label.blit surface, rect
end

catch :quit do
	loop do
		delta = clock.tick.seconds
		event_queue.each do |event|
			case event
				when Events::QuitRequested then throw :quit
				when Events::KeyboardEvent 
					$turn_over = $villain.handle event unless ($win || $lose)
			end
		end
		if $turn_over
			$win = world.update
			$lose = $hero.action unless $win
			$turn_over = false
		end
		world.draw $screen
		$hero.draw $screen
		$villain.draw $screen
		gameover $screen, "Villain Won" if $win
		gameover $screen, "Villain Lost" if $lose
		$screen.flip
	end
end
