extends Node


class Cultivator:
	var num = {}
	var flag = {}
	var obj = {}

	func _init(input_):
		num.index = Global.num.primary_key.cultivator
		Global.num.primary_key.cultivator += 1
		init_nums()
		jump_stages(input_.stage)
		calc_volume()
		calc_power()
		flag.alarm = false
		obj.sect = input_.sect
		obj.cohort = null

	func init_nums():
		num.growth = {}
		set_growth()
		num.volume = {}
		num.volume.base = 10
		num.volume.degree = 3
		num.volume.factor = 1
		num.volume.over = 0
		num.stage = {}
		num.stage.current = 0
		num.stage.elevation = 0
		num.stage.span = 0
		num.stage.floor = 0
		num.enlightenment = {}
		num.enlightenment.current = 0
		num.art = {}
		num.art.avg = 1
		num.power = {}
		num.damage = {}
		num.damage.current = 10
		num.reload = {}
		num.reload.current = 12
		num.health = {}
		num.health.max = 100
		num.health.current = num.health.max
		num.defense = {}
		num.defense.current = 20
		num.defense.factor = 0
		num.recovery = {}
		num.recovery.health = 1

	func jump_stages(value_):
		for _i in value_:
			next_stage()

	func next_stage():
		num.stage.current += 1
		unpdate_enlightenment()
		next_elevation()
		num.volume.factor += float(num.growth.talent-num.stage.span)/100
		num.volume.base += 1

	func next_elevation():
		num.stage.elevation += 1
		
		if num.stage.elevation == Global.arr.elevation.size():
			num.stage.span += 1
			num.stage.elevation = 0
			
			if num.stage.span == Global.num.span.bottleneck:
				check_bottleneck()

	func check_bottleneck():
		var success = true
		
		#check
		
		if success:
			num.stage.span = 0
			num.stage.floor += 1
		else:
			num.stage.span -= 1
			num.stage.current -= 1
			num.stage.elevation = Global.arr.elevation.size()
			unpdate_enlightenment()

	func unpdate_enlightenment():
		num.enlightenment.max = pow((num.stage.current+2),2)

	func get_enlightenment(value_):
		num.enlightenment.current += value_
		
		while num.enlightenment.current >= num.enlightenment.max:
			num.enlightenment.current -= num.enlightenment.max
			next_stage()

	func calc_defense_factor():
		if num.defense.current > 0:
			num.defense.factor = 100/(100+num.defense.current)
		else:
			num.defense.factor = -(2 - 100/(100+num.defense.current))

	func calc_volume():
		num.volume.current = pow(num.volume.base, num.volume.degree)*num.volume.factor

	func calc_power():
		num.power.current = num.volume.current*num.art.avg 

	func set_growth():
		Global.rng.randomize()
		var index_r = Global.rng.randi_range(0, Global.arr.talent.size()-1)
		num.growth.talent = Global.arr.talent[index_r]
		num.growth.genius = 1

class Sect:
	var num = {}
	var arr = {}
	var flag = {}
	var obj = {}

	func _init(input_):
		num.index = Global.num.primary_key.cultivator
		Global.num.primary_key.cultivator += 1
		arr.cultivator = []
		obj.village = input_.village
		
		init_cultivators()

	func init_cultivators():
		var strongest = Global.arr.elevation.size()*Global.num.span.bottleneck
		var weakest = 0
		
		for _i in range(weakest,strongest,1):
			var prevalence = strongest-_i
			
			for _j in prevalence:
				var input = {}
				input.stage = _i
				input.sect = self
				var cultivator = Classes_Arena.Cultivator.new(input)
				arr.cultivator.append(cultivator)

class Cohort:
	var num = {}
	var arr = {}
	var flag = {}
	var obj = {}
	
	func _init(input_):
		obj.sect = input_.sect
		obj.arena = input_.arena
		arr.cultivator = []

class Battlefield:
	var num = {}
	var word = {}
	var dict = {}
	var flag = {}
	var obj = {}

	func _init(input_):
		obj.arena = input_.arena
		word.rule = input_.rule
		obj.vexillary = null
		dict.cultivators = {}
		dict.perspectives = {}
		
		for village in obj.arena.dict.data.keys():
			dict.cultivators[village] = []
			dict.perspectives[village] = {}
			dict.perspectives[village].combos = {}

	func calc_perspectives(village_):
		if dict.perspectives[village_].combos.keys().size() == 0:
			var cultivators = []
			var starts = []
			
			for troop in obj.arena.dict.data[village_].troops:
				for cultivator in troop.cultivators:
					cultivators.append(cultivator)
					
					if !starts.has(cultivator.num.stage.current):
						starts.append(cultivator.num.stage.current)
			
			starts.sort()
			
			for start in starts:
				dict.perspectives[village_].combos[start] = {}
				dict.perspectives[village_].combos[start].components = {}
				dict.perspectives[village_].combos[start].alternatives = 1
				dict.perspectives[village_].combos[start].prize = 1
			
			match word.rule:
				"Same Stage":#, "Full Span", "Ordered Elevation"
					for start in starts:
						for _i in Global.num.battlefield.combo:
							dict.perspectives[village_].combos[start].components[start] = 0
				"Full Span":
					for start in starts:
						for _i in Global.num.battlefield.combo:
							dict.perspectives[village_].combos[start].components[start+_i] = 0
				"Ordered Elevation":
					for start in starts:
						for _i in Global.num.battlefield.combo:
							dict.perspectives[village_].combos[start].components[start+_i*Global.arr.elevation.size()] = 0
			
			for cultivator in cultivators:
				for start in dict.perspectives[village_].combos.keys():
					if dict.perspectives[village_].combos[start].components.has(cultivator.num.stage.current):
						dict.perspectives[village_].combos[start].components[cultivator.num.stage.current] += 1
			
			match word.rule:
				"Same Stage":
					for start in dict.perspectives[village_].combos.keys():
						if dict.perspectives[village_].combos[start].components[start] < Global.arr.elevation.size():
							dict.perspectives[village_].combos.erase(start)
				"Full Span":
					for start in dict.perspectives[village_].combos.keys():
						if start % Global.arr.elevation.size() != 0:
							dict.perspectives[village_].combos.erase(start)
			
			for start in dict.perspectives[village_].combos.keys():
				var flag = false
				
				for key in dict.perspectives[village_].combos[start].components.keys():
					var value = dict.perspectives[village_].combos[start].components[key]
					flag = flag || value <= 0
				
				if flag:
					dict.perspectives[village_].combos.erase(start)
			
			for start in dict.perspectives[village_].combos.keys():
				for key in dict.perspectives[village_].combos[start].components.keys():
					var value = dict.perspectives[village_].combos[start].components[key]
					dict.perspectives[village_].combos[start].alternatives *= value
					dict.perspectives[village_].combos[start].prize += key
					
				if word.rule == "Same Stage":
					var value = dict.perspectives[village_].combos[start].components[start]
					dict.perspectives[village_].combos[start].alternatives = Global.conjunction(value,Global.num.battlefield.combo)					
					dict.perspectives[village_].combos[start].prize *= (Global.num.battlefield.combo-1)
		else:
			pass

class Arena:
	var num = {}
	var obj = {}
	var arr = {}
	var dict = {}
	var flag = {}

	func _init(input_):
		num.index = Global.num.primary_key.arena
		Global.num.primary_key.arena += 1
		num.round = -1
		num.timer = {}
		num.timer.max = Global.num.arena.timer
		num.timer.current = num.timer.max
		num.timer.total = 0
		obj.road = input_.road
		obj.map = input_.road.arr.village.front().obj.map
		obj.winner = null
		dict.data = {}
		dict.analysis = {}
		flag.reinforcement = true
		
		for village in input_.road.arr.village:
			village.arr.arena.append(self)
			dict.data[village] = {}
			dict.data[village].n = 0
			dict.data[village].sum = 0
			dict.data[village].avg = 0
			dict.data[village].delay = 0
			dict.data[village].cohorts = []
			dict.data[village].reserve = []

	func get_rivals(village_):
		var rivals = []
		rivals.append_array(dict.data.keys())
		rivals.erase(village_)
		return rivals

	func get_cohorts(village_):
		for village in dict.data.keys():
			if dict.data[village].cohorts.front().obj.sect.obj.village == village_:
				return dict.data[village].cohorts
		
		return null

	func add_cultivators(village_, cultivators_):
		for cultivator in cultivators_:
			for cohort in dict.data[village_].cohorts:
				if cultivator.obj.sect == cohort.obj.sect:
					cohort.arr.cultivator.append(cultivator)
					dict.data[village_].n += 1
					dict.data[village_].sum += cultivator.num.power.current
					cultivator.obj.cohort = cohort
		
		dict.data[village_].avg = dict.data[village_].sum/dict.data[village_].n

	func contest():
		prepare_battlefields()
		prepare_troops()
		start_contest()

	func prepare_battlefields():
		arr.battlefield = []
		var options = []
		options.append_array(Global.dict.battlefield.rule)
		
		for _i in Global.num.arena.battlefields:
			Global.rng.randomize()
			var index_r = Global.rng.randi_range(0, options.size()-1)
			var input = {}
			input.arena = self
			input.rule = options.pop_at(index_r)
			var battlefield = Classes_Arena.Battlefield.new(input)
			arr.battlefield.append(battlefield)
			dict.analysis[battlefield] = {}

	func prepare_troops():
		for village in dict.data.keys():
			get_troops(village)
			order_troops(village)

	func get_troops(village_):
		var options = []
		
		for cohort in dict.data[village_].cohorts:
			for cultivator in cohort.arr.cultivator:
				options.append(cultivator)
		
		options.shuffle()
		dict.data[village_].troops = []
		var troop_size = options.size()/Global.num.arena.rounds
		var counter = 0
		
		for _i in Global.num.arena.rounds:
			var troop = {}
			troop.cultivators = []
			troop.order = -1
			troop.value = 0
			
			for _j in troop_size:
				var cultivator = options[counter]
				troop.cultivators.append(cultivator)
				troop.value += cultivator.num.power.current
				counter += 1
			
			dict.data[village_].troops.append(troop)

	func order_troops(village_):
		var priority = village_.roll_priority("troop")
		
		match priority:
			"Ambush":
				dict.data[village_].troops.sort_custom(Classes_Map.Sorter, "sort_descending")
			"Swoop":
				dict.data[village_].troops.sort_custom(Classes_Map.Sorter, "sort_ascending")
		
		for _i in dict.data[village_].troops.size():
			dict.data[village_].troops[_i].order = _i

	func start_contest():
		check_round()
		bring_cultivator()
		#rint(dict.reserve)

	func refill_reserve():
		if flag.reinforcement:
			for village in dict.data.keys():
				for cultivator in dict.data[village].troops[num.round].cultivators:
					dict.data[village].reserve.append(cultivator)

	func bring_cultivator():
		for village in dict.data.keys():
			if dict.data[village].delay == num.timer.total:
				analysis_battlefields(village)

	func analysis_battlefields(village_):
		for battlefield in arr.battlefield:
			battlefield.calc_perspectives(village_)
		
		size_possibilities(village_)

	func size_possibilities(village_):
		var datas = []
		
		for battlefield in arr.battlefield:
			var combos = battlefield.dict.perspectives[village_].combos
			
			for start in combos.keys():
				var data = {}
				data.battlefield = battlefield
				data.components = []
				data.alternatives = combos[start].alternatives
				data.prize = combos[start].prize
				data.value = 0
				
				for key in combos[start].components.keys():
					data.components.append(key)
				
				datas.append(data)
		print(datas)

	func check_round():
		if num.round < Global.num.arena.rounds:
			if num.timer.current >= num.timer.max:
				num.round += 1
				refill_reserve()
				num.timer.current -= num.timer.max
