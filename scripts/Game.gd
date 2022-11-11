extends Node


func _ready():
	Global.obj.map = Classes.Map.new()
	
#	Global.rng.randomize()
#	var index_r = Global.rng.randi_range(0, options.size()-1)
	
#	var path = "res://json/"
#	var name_ = "name"
#	var data = ""
#	Global.save_json(data,path,name_)

func _input(event):
	if event is InputEventMouseButton:
		if Global.flag.click:
			pass
		else:
			Global.flag.click = !Global.flag.click

func _process(delta):
	pass

func _on_Timer_timeout():
	Global.node.TimeBar.value +=1
	
	if Global.node.TimeBar.value >= Global.node.TimeBar.max_value:
		Global.node.TimeBar.value -= Global.node.TimeBar.max_value
