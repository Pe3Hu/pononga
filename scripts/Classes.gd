extends Node


class Vicinity:
	var num = {}
	var vec = {}
	var obj = {}
	var arr = {}
	var flag = {}
	var color = {}

	func _init(input_):
		num.index = Global.num.primary_key.vicinity
		Global.num.primary_key.vicinity += 1
		vec.grid = input_.grid
		vec.center = input_.grid * Global.num.vicinity.a + Global.vec.map
		arr.point = []
		arr.region = []
		arr.neighbor = []
		arr.associated = []
		arr.delimited = []
		flag.free = true
		flag.visiable = true
		flag.capital = false
		set_points()
		num.ring = get_ring(Vector2(Global.num.map.rows/2,Global.num.map.cols/2))
		color.background = Color().from_hsv(0,0,1.0) 
		#var h = float(num.ring)/Global.num.map.rings
		#color.background = Color().from_hsv(h,1.0,1.0) 
		
		for _i in Global.num.region.ranks:
			arr.region.append(-1)

	func get_ring(vec_):
		var x = abs(vec.grid.x-vec_.x)
		var y = abs(vec.grid.y-vec_.y)
		return max(x,y)

	func set_points():
		for point in Global.arr.point:
			var vertex = point * Global.num.vicinity.a/2 + vec.center
			arr.point.append(vertex)

class Region:
	var num = {}
	var arr = {}
	var flag = {}

	func _init(input_):
		num.index = Global.num.primary_key.region
		Global.num.primary_key.region += 1
		num.rank = input_.rank
		flag.union = false
		arr.vicinity = []

	func add_vicinity(vicinity_):
		arr.vicinity.append(vicinity_)
		vicinity_.arr.region[num.rank] = num.index
		
		for neigbhor in vicinity_.arr.neighbor:
			if arr.vicinity.has(neigbhor):
				vicinity_.arr.associated.append(neigbhor)
			
			vicinity_.arr.delimited.erase(neigbhor)
			neigbhor.arr.delimited.erase(vicinity_)
		
		if arr.vicinity.size() == 3:
			flag.union = true

class Village:
	var num = {}
	var arr = {}
	var obj = {}

	func _init(input_):
		num.index = Global.num.primary_key.village
		Global.num.primary_key.village += 1
		arr.vicinity = []
		obj.capital = input_.capital
		obj.capital.flag.capital = true

class Map:
	var num = {}
	var arr = {}

	func _init():
		arr.vicinity = []
		arr.region = []
		arr.village = []
		init_vicinitys()
		init_borderlands()
		init_regions()
		init_sectors()
		init_villages()

	func init_vicinitys():
		for _i in Global.num.map.rows:
			arr.vicinity.append([])
			
			for _j in Global.num.map.cols:
				var input = {}
				input.grid = Vector2(_j,_i)
				var vicinity = Classes.Vicinity.new(input)
				arr.vicinity[_i].append(vicinity)

	func init_borderlands():
		arr.borderland = []

		for vicinitys in arr.vicinity:
			for vicinity in vicinitys:
				for neighbor in Global.arr.neighbor:
					var grid = vicinity.vec.grid + neighbor

					if check_border(grid):
						var neighbor_vicinity = arr.vicinity[grid.y][grid.x]
						add_borderland(vicinity,neighbor_vicinity)

	func add_borderland(parent_vicinity_,child_vicinity_):
		if !parent_vicinity_.arr.neighbor.has(child_vicinity_):
			parent_vicinity_.arr.neighbor.append(child_vicinity_)
			child_vicinity_.arr.neighbor.append(parent_vicinity_)
			parent_vicinity_.arr.delimited.append(child_vicinity_)
			child_vicinity_.arr.delimited.append(parent_vicinity_)

	func init_regions():
		init_associates()
		
		#while arr.region.size() < Global.num.region.ranks:
			#var rank = arr.region.size() - 1
			
			#for region in arr.region[rank]:
		pass

	func init_associates():
		arr.region.append([])
		var unused = []
		
		for vicinitys in arr.vicinity:
			for vicinity in vicinitys:
				unused.append(vicinity)
		
		while unused.size() > Global.num.associate.size:
			generate_associate(unused)
		
		if unused.size() > 0:
			generate_associate(unused)
			var isolated = detect_isolated(unused)
			
			if isolated != null:
				shift_isolated(isolated)
		
		for region in arr.region[0]:
			for vicinity in region.arr.vicinity:
				var hue = float(region.num.index)/float(arr.region[0].size())
				vicinity.color.background = Color().from_hsv(hue,1,1) 
		pass

	func generate_associate(unused_):
		var rank = 0
		var input = {}
		input.rank = rank
		var region = Classes.Region.new(input)
		arr.region[rank].append(region)
		var begin = corner_vicinity(unused_)
		region.add_vicinity(begin)
		var vicinitys = [begin]
		var flag = true
		
		while vicinitys.size() < Global.num.associate.size && flag:
			var options = []
			
			for vicinity in vicinitys:
				for neighbor in vicinity.arr.neighbor:
					if neighbor.flag.free:
						var mid = round(Global.num.map.half)
#						var d = max(abs(mid-neighbor.vec.grid.x),abs(mid-neighbor.vec.grid.y))
#						var n = d + 1
#						for _i in pow(n,3): 
#							options.append(neighbor)
						var option = {}
						option.n = neighbor.arr.delimited.size()
						option.d = max(abs(mid-neighbor.vec.grid.x),abs(mid-neighbor.vec.grid.y))
						option.neighbor = neighbor
						options.append(option)
			
			var min_n = Global.arr.neighbor.size()
			
			for option in options:
				if min_n > option.n:
					min_n = option.n
			
			for option in options:
				if min_n != option.n:
					options.erase(option)
			
			var max_d = 0
			
			for option in options:
				if option.d > max_d:
					max_d = option.d
			
			for option in options:
				if max_d != option.d:
					options.erase(option)
			
			if options.size() > 0:
				Global.rng.randomize()
				var index_r = Global.rng.randi_range(0, options.size()-1)
				var option = options[index_r].neighbor
				unused_.erase(option)
				option.flag.free = false
				vicinitys.append(option)
				region.add_vicinity(option)
			else:
				flag = false

	func corner_vicinity(unused_):
		var min_neighbor = Global.arr.neighbor.size()
		var options = []
		
		for vicinity in unused_:
			if min_neighbor > vicinity.arr.delimited.size():
				min_neighbor = vicinity.arr.delimited.size()
		
		for vicinity in unused_:
			if min_neighbor == vicinity.arr.delimited.size():
				options.append(vicinity)
		
		var mid = round(Global.num.map.half)
		var max_far_away = 0
		
		for option in options:
			var d = abs(mid-option.vec.grid.x)+abs(mid-option.vec.grid.y)
			
			if d > max_far_away:
				max_far_away = d
		
		var options_2 = []
		
		for option in options:
			var d = abs(mid-option.vec.grid.x)+abs(mid-option.vec.grid.y)
		
			if d == max_far_away:
				options_2.append(option)
		
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, options_2.size()-1) 
		var option = options_2[index_r]
		unused_.erase(option)
		option.flag.free = false
		return option

	func detect_isolated(unused_):
		for option in unused_:
			if option.arr.delimited.size() == 0:
				return option

		return null

	func shift_isolated(isolated_):
		var regions = []
		var rank = 0

		for neighbor in isolated_.arr.neighbor:
			regions.append(neighbor.arr.region[rank])

		var options = []

		for _i in regions:
			var region = arr.region[rank][_i]
			for vicinity in region.arr.vicinity:
				for neighbor in vicinity.arr.neighbor:
					if neighbor.flag.free:
						options.append(region)


		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, options.size()-1)
		var region = options[index_r]
		#var swap = 
		#region.add_vicinity(isolated_)

	func init_sectors():
		var vicinity_counters = []
		var sum = 0
		
		for _i in Global.num.map.rings:
			vicinity_counters.append(0)
		
		for vicinitys in arr.vicinity:
			for vicinity in vicinitys:
				if vicinity.num.ring != -1:
					vicinity_counters[vicinity.num.ring] += 1
					sum += 1
		
		var sector_sums = []
		var sector_begins = [0]
		var sector_ends = []
		
		for _i in Global.num.map.sectors:
			sector_sums.append(0)
		
		for _i in vicinity_counters.size():
			if sector_ends.size() < sector_sums.size():
				sector_sums[sector_ends.size()] += vicinity_counters[_i]
				
				if sector_sums[sector_ends.size()] >= sum/Global.num.map.sectors:
					if sector_ends.size() < Global.num.map.sectors:
						sector_sums[sector_ends.size()] -= vicinity_counters[_i]
					
					sector_ends.append(_i-1)
					
					if sector_ends.size() != Global.num.map.sectors:
						sector_sums[sector_ends.size()] += vicinity_counters[_i]
						sector_begins.append(sector_ends.back()+1)
					else:
						sector_sums[sector_ends.size()-1] += vicinity_counters[_i]
		
		if sector_ends.size() == Global.num.map.sectors:
			sector_ends.pop_back()
		
		sector_ends.append(Global.num.map.rings-1)
		var ring_to_sector = []
		
		for _i in Global.num.map.sectors:
			for ring_ in sector_ends[_i]-sector_begins[_i]+1:
				ring_to_sector.append(_i)
		
		for vicinitys in arr.vicinity:
			for vicinity in vicinitys:
				vicinity.num.sector = ring_to_sector[vicinity.num.ring]

	func init_villages():
		var options = []
		var sectors = []
		
		for _i in range(1,Global.num.map.sectors-1):
			sectors.append(_i) 
		
		for vicinitys in arr.vicinity:
			for vicinity in vicinitys:
				if sectors.has(vicinity.num.sector):
					options.append(vicinity)
		
		while options.size() > 0:
			Global.rng.randomize()
			var index_r = Global.rng.randi_range(0, options.size()-1)
			var input = {}
			input.capital = options[index_r]
			var village = Classes.Village.new(input)
			arr.village.append(village)
			
			var arounds = [input.capital]
			
			for _i in Global.num.village.estrangement:
				for _j in range(arounds.size()-1,-1,-1):
					for neighbor in arounds[_j].arr.neighbor:
						if !arounds.has(neighbor):
							arounds.append(neighbor)
			
			for around in arounds:
				options.erase(around)

	func check_border(grid_):
		return grid_.x >= 0 && grid_.x < Global.num.map.cols && grid_.y >= 0 && grid_.y < Global.num.map.rows

class Sorter:
	static func sort_ascending(a, b):
		if a.value < b.value:
			return true
		return false

	static func sort_descending(a, b):
		if a.value > b.value:
			return true
		return false
