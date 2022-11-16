extends Node2D


func _draw():
	for vicinitys in Global.obj.map.arr.vicinity:
		for vicinity in vicinitys:
			if vicinity.flag.visiable:
				draw_polygon(vicinity.arr.point, PoolColorArray([vicinity.color.background]))
			if vicinity.flag.capital:
				var color = Color.black
				
				if vicinity.obj.village.flag.arenas:
					color = Color.white
				
				#if vicinity.obj.village.flag.interior:
				#	color  = Color.blue
	
					
				draw_circle(vicinity.vec.center, Global.num.vicinity.a/4, color)
				
	for road in Global.obj.map.arr.road:
		if road.flag.arena:
			draw_line(road.arr.point.front(), road.arr.point.back(), road.color.line, Global.num.road.width)

func _process(delta):
	update()
