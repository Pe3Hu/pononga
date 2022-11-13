extends Node


class Vicinity:
	var num = {}
	var vec = {}
	var arr = {}
	var flag = {}
	var color = {}
	var obj = {}

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
		
		for _i in Global.num.region.pow:
			arr.region.append(null)

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
	var obj = {}
	var flag = {}

	func _init(input_):
		num.index = Global.num.primary_key.region
		Global.num.primary_key.region += 1
		num.rank = input_.rank
		obj.map = input_.map
		flag.union = false
		arr.vicinity = []
		arr.region = []
		arr.neighbor = []
		arr.domain = []
		arr.domain.append_array(Global.arr.domain)

	func add_vicinity(vicinity_):
		arr.vicinity.append(vicinity_)
		vicinity_.arr.region[num.rank] = self
		
		if num.rank == 0:
			for neigbhor in vicinity_.arr.neighbor:
				if arr.vicinity.has(neigbhor):
					vicinity_.arr.associated.append(neigbhor)
				
				vicinity_.arr.delimited.erase(neigbhor)
				neigbhor.arr.delimited.erase(vicinity_)
			
			if arr.vicinity.size() == 3:
				flag.union = true

	func update_domain_by(vicinity_):
		if arr.domain.has(vicinity_.arr.domain.front()):
			if arr.domain.size() > 1:
				arr.domain.erase(vicinity_.arr.domain.front())
			
				if arr.domain.size() == 1:
					for neighbor in arr.neighbor:
						neighbor.update_domain_by(self)
			else:
				print("update_domain error 1",arr.domain)
				obj.map.flag.domain = false

	func add_region(region_):
		arr.region.append(region_)
		
		for vicinity in region_.arr.vicinity:
			add_vicinity(vicinity)
			
		if arr.region.size() == 3:
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
	var flag = {}

	func _init():
		arr.vicinity = []
		arr.region = []
		arr.village = []
		flag.domain = false
		flag.rank = false
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
				for vec in Global.arr.neighbor:
					var grid = vicinity.vec.grid + vec

					if check_border(grid):
						var neighbor = arr.vicinity[grid.y][grid.x]
						add_borderland(vicinity,neighbor)

	func add_borderland(parent_vicinity_,child_vicinity_):
		if !parent_vicinity_.arr.neighbor.has(child_vicinity_):
			parent_vicinity_.arr.neighbor.append(child_vicinity_)
			child_vicinity_.arr.neighbor.append(parent_vicinity_)
			parent_vicinity_.arr.delimited.append(child_vicinity_)
			child_vicinity_.arr.delimited.append(parent_vicinity_)

	func init_regions():
		init_associates()
		set_region_neighbors(0)
		init_region_ranks()
		#set_4_domains()
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
		
#		for region in arr.region[0]:
#			for vicinity in region.arr.vicinity:
#				var hue = float(region.num.index)/float(arr.region[0].size())
#				vicinity.color.background = Color().from_hsv(hue,1,1) 
		pass

	func generate_associate(unused_):
		var rank = 0
		var input = {}
		input.rank = rank
		input.map = self
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

	func set_region_neighbors(rank_):
		for region in arr.region[rank_]:
			for vicinity in region.arr.vicinity:
				for neighbor in vicinity.arr.neighbor:
					if neighbor.arr.region[rank_] != vicinity.arr.region[rank_] && neighbor.arr.region[rank_] != null:
						if !region.arr.neighbor.has(neighbor.arr.region[rank_]):
							region.arr.neighbor.append(neighbor.arr.region[rank_])
							neighbor.arr.region[rank_].arr.neighbor.append(region)

	func init_region_ranks():
		var rank = arr.region.size()-1
		var ununioned_vicinitys = []
		
		for region in arr.region[rank]:
			if !region.flag.union:
				for vicinity in region.arr.vicinity:
					ununioned_vicinitys.append(vicinity) 
		
		while rank < Global.num.region.ranks-1:
			flag.rank = false
			print("______",rank)
			arr.region.append([])
			
			while !flag.rank:
				flag.rank = true
				var free_regions = []
				var ununioned_regions = []
				arr.region[rank+1] = []
				
				for region in arr.region[rank]:
					if region.flag.union:
						free_regions.append(region)
					else:
						ununioned_regions.append(region)
				
				while free_regions.size() % Global.num.region.base != 0:
					var options = []
					
					for region in ununioned_regions:
						for neighbor in region.arr.neighbor:
							if free_regions.has(neighbor):
								options.append(neighbor)
					
					Global.rng.randomize()
					var index_r = Global.rng.randi_range(0, options.size()-1)
					var region = options[index_r]
					free_regions.erase(region)
					ununioned_regions.append(region)
				
				while free_regions.size() >= Global.num.region.base && flag.rank:
					var datas = []
					
					for region in free_regions:
						var data = {}
						data.value = 0
						data.region = region
						
						for neighbor in region.arr.neighbor:
							if free_regions.has(neighbor):
								data.value += 1
						
						datas.append(data)
						
					datas.sort_custom(Sorter, "sort_ascending")
					var options = []
					
					for data in datas:
						if data.value == datas.front().value:
							options.append(data)
					
					Global.rng.randomize()
					var index_r = Global.rng.randi_range(0, options.size()-1)
					
					if options[index_r].value > 0:
						var regions = [options[index_r].region]
						free_regions.erase(regions.back())
						
						while Global.num.region.base > regions.size() && flag.rank:
							var datas_2 = []
							
							for region in regions:
								for neighbor in region.arr.neighbor:
									var data = {}
									data.value = 0
									data.region = neighbor
									
									if free_regions.has(neighbor) && !regions.has(neighbor):
										datas_2.append(data)
							#print("datas_2 :",datas_2.size())
							if datas_2.size() == 0:
								print("init_region_ranks fail 0")
								flag.rank = false
							else:
								for data_2 in datas_2:
									for neighbor in data_2.region.arr.neighbor:
										if free_regions.has(neighbor) && !regions.has(neighbor):
											data_2.value += 1
								
								datas_2.sort_custom(Sorter, "sort_ascending")
								regions.append(datas_2.front().region)
								free_regions.erase(datas_2.front().region)
						
						var input = {}
						input.rank = rank+1
						input.map = self
						var new_region = Classes.Region.new(input)
						
						if regions.size() != 3:
							print("init_region_ranks fail 1")
							flag.rank = false
						
						for region in regions:
							new_region.add_region(region)
							
						arr.region[rank+1].append(new_region)
					else:
						datas = []
				
				if ununioned_regions.size() > 0:
					var input = {}
					input.rank = rank+1
					input.map = self
					var ununioned_region = Classes.Region.new(input)
					
					for region in ununioned_regions:
						ununioned_region.add_region(region)
						
					ununioned_region.flag.union = false
				
					arr.region[rank+1].append(ununioned_region)
				
				if flag.rank:
					check_rank(rank+1)
					
				print(flag.rank,arr.region[rank+1].size())
			
			rank += 1
			set_region_neighbors(rank)
		
		#for regions in arr.region:
		#	print(regions.size())
		
		#var sum = 0
		
		for _i in arr.region[rank].size():
			#sum += arr.region[rank][_i].arr.vicinity.size()
			
			for vicinity in arr.region[rank][_i].arr.vicinity:
				var hue = float(_i)/float(arr.region[rank].size())
				vicinity.color.background = Color().from_hsv(hue,1,1) 
		
		#print(sum, "=",Global.num.vicinity.count)

	func set_4_domains():
		var rank = 0
		var domains = [0,0,0,0]
		
		while !flag.domain:
			flag.domain = true
		
			for vicinitys in arr.vicinity:
				for vicinity in vicinitys:
					var region = vicinity.arr.region[rank]
					
					if region.flag.union && region.arr.domain.size() > 1:
						Global.rng.randomize()
						var index_r = Global.rng.randi_range(0, region.arr.domain.size()-1)
						region.arr.domain = [region.arr.domain[index_r]]
						
						for neighbor in region.arr.neighbor:
							neighbor.update_domain_by(region)
		
		for region in arr.region[rank]:
			if region.flag.union:
				domains[region.arr.domain.front()] += 1
		
		print(domains,float(arr.region[rank].size())/4)
		
		for region in arr.region[rank]:
			for vicinity in region.arr.vicinity:
				if region.arr.domain.size() == 1 && region.flag.union:
					var hue = float(region.arr.domain.front())/Global.arr.domain.size()
					vicinity.color.background = Color().from_hsv(hue,1,1) 

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

	func check_rank(rank_):
		var sum = 0
		
		for region in arr.region[rank_]:
			for vicinity in region.arr.vicinity:
				sum += 1
	
		flag.rank = sum == Global.num.vicinity.count

class Sorter:
	static func sort_ascending(a, b):
		if a.value < b.value:
			return true
		return false

	static func sort_descending(a, b):
		if a.value > b.value:
			return true
		return false
