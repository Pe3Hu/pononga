extends Node2D


func _draw():
	for vicinitys in Global.obj.map.arr.vicinity:
		for vicinity in vicinitys:
			if vicinity.flag.visiable:
				draw_polygon(vicinity.arr.point, PoolColorArray([vicinity.color.background]))
			if vicinity.flag.capital:
				draw_circle(vicinity.vec.center, Global.num.vicinity.a/4, Color(0.0, 0.0, 0.0))

func _process(delta):
	update()
