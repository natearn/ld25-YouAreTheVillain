
require 'rubygame'
include Rubygame

Surface.new([640,480]).fill(:blue).savebmp("world.bmp")
Surface.new([64,64]).draw_circle_s([32,32],31,:red).savebmp("city.bmp")
Surface.new([8,8]).draw_circle_s([4,4],4,:yellow).savebmp("hero.bmp")
Surface.new([8,8]).draw_circle_s([4,4],4,:green).savebmp("villain.bmp")
