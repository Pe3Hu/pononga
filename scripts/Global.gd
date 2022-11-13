extends Node


var rng = RandomNumberGenerator.new()
var num = {}
var dict = {}
var arr = {}
var obj = {}
var node = {}
var flag = {}
var vec = {}

func init_num():
	init_primary_key()
	
	num.map = {}
	num.map.rings = 14
	num.map.n = num.map.rings*2-1
	num.map.sectors = 7
	num.map.cols = num.map.n
	num.map.rows = num.map.n
	num.map.half = min(num.map.cols,num.map.rows)/2
	num.map.l = min(dict.window_size.width,dict.window_size.height) * 0.9
	
	num.vicinity = {}
	num.vicinity.count = num.map.cols*num.map.rows
	num.vicinity.a = num.map.l/min(num.map.cols,num.map.rows)
	
	num.region = {}
	num.region.base = 3
	num.region.pow = int(custom_log(num.vicinity.count,num.region.base))
	num.region.ranks = num.region.pow-1
	
	num.associate = {}
	num.associate.size = 3
	
	num.village = {}
	num.village.estrangement = 3
	
	num.rank = {}
	num.rank.current = num.region.ranks-1

func init_primary_key():
	num.primary_key = {}
	num.primary_key.vicinity = 0
	num.primary_key.region = 0
	num.primary_key.village = 0

func init_dict():
	init_window_size()

func init_window_size():
	dict.window_size = {}
	dict.window_size.width = ProjectSettings.get_setting("display/window/size/width")
	dict.window_size.height = ProjectSettings.get_setting("display/window/size/height")
	dict.window_size.center = Vector2(dict.window_size.width/2, dict.window_size.height/2)

func init_arr():
	arr.sequence = {} 
	arr.sequence["A000040"] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
	arr.sequence["A000045"] = [89, 55, 34, 21, 13, 8, 5, 3, 2, 1, 1]
	arr.sequence["A000124"] = [7, 11, 16] #, 22, 29, 37, 46, 56, 67, 79, 92, 106, 121, 137, 154, 172, 191, 211]
	arr.sequence["A001358"] = [4, 6, 9, 10, 14, 15, 21, 22, 25, 26]
	arr.point = [
		Vector2( 1,-1),
		Vector2( 1, 1),
		Vector2(-1, 1),
		Vector2(-1,-1)
	]
	arr.neighbor = [
		Vector2( 0,-1),
		Vector2( 1, 0),
		Vector2( 0, 1),
		Vector2(-1, 0)
	]
	arr.domain = [0,1,2,3]

func init_node():
	node.TimeBar = get_node("/root/Game/TimeBar") 
	node.Game = get_node("/root/Game") 

func init_flag():
	flag.click = false
	flag.stop = false

func init_vec():
	vec.map = dict.window_size.center - Vector2(num.map.cols*num.vicinity.a/2,num.map.rows*num.vicinity.a/2)

func _ready():
	init_dict()
	init_num()
	init_arr()
	init_node()
	init_flag()
	init_vec()

func save_json(data_,file_path_,file_name_):
	var file = File.new()
	file.open(file_path_+file_name_+".json", File.WRITE)
	file.store_line(to_json(data_))
	file.close()

func load_json(file_path_,file_name_):
	var file = File.new()
	
	if not file.file_exists(file_path_+file_name_+".json"):
			 #save_json()
			 return null
	
	file.open(file_path_+file_name_+".json", File.READ)
	var data = parse_json(file.get_as_text())
	return data

func custom_log(value_,base_): 
	return log(value_)/log(base_)

func next_rank():
	num.rank.current = (num.rank.current+1)%num.region.ranks
	
	for _i in obj.map.arr.region[num.rank.current].size():
		for vicinity in obj.map.arr.region[num.rank.current][_i].arr.vicinity:
			var hue = float(_i)/float(obj.map.arr.region[num.rank.current].size())
			vicinity.color.background = Color().from_hsv(hue,1,1) 
