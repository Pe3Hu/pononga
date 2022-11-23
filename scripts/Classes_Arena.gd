extends Node


class Cultivator:
	var num = {}
	var flag = {}
	var obj = {}

	func _init(input_):
		num.index = Global.num.primary_key.cultivator
		Global.num.primary_key.cultivator += 1
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
		jump_stages(input_.stage)
		calc_volume()
		num.art = {}
		num.art.avg = 1
		num.power = {}
		calc_power()
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
		flag.alarm = false
		obj.sect = input_.sect
		obj.cohort = null

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
	var dict = {}
	var flag = {}
	var obj = {}
	
	func _init(input_):
		obj.arena = input_.arena
		dict.cultivators = {}
		
		for village in obj.arena.dict.cohorts.keys():
			dict.cultivators[village] = []

class Arena:
	var num = {}
	var dict = {}
	var obj = {}

	func _init(input_):
		num.index = Global.num.primary_key.arena
		Global.num.primary_key.arena += 1
		obj.road = input_.road
		obj.map = input_.road.arr.village.front().obj.map
		dict.cohorts = {}
		dict.data = {}
		
		for village in input_.road.arr.village:
			village.arr.arena.append(self)
			dict.cohorts[village] = []
			dict.data[village] = {}
			dict.data[village].n = 0
			dict.data[village].sum = 0
			dict.data[village].avg = 0

	func get_rivals(village_):
		var rivals = []
		rivals.append_array(dict.cohorts.keys())
		rivals.erase(village_)
		return rivals

	func get_cohorts(village_):
		for village in dict.cohorts.keys():
			if dict.cohorts[village].front().obj.sect.obj.village == village_:
				return dict.cohorts[village]
		
		return null

	func add_cultivators(village_, cultivators_):
		for cultivator in cultivators_:
			for cohort in dict.cohorts[village_]:
				if cultivator.obj.sect == cohort.obj.sect:
					cohort.arr.cultivator.append(cultivator)
					dict.data[village_].n += 1
					dict.data[village_].sum += cultivator.num.power.current
					cultivator.obj.cohort = cohort
		
		dict.data[village_].avg = dict.data[village_].sum/dict.data[village_].n

	func contest():
		for village in dict.cohorts.keys():
			var troop = get_troop(village)

	func get_troop(village_):
		var options = []
		
		for cohort in dict.cohorts[village_]:
			for cultivator in cohort.arr.cultivator:
				options.append(cultivator)
		
		options.shuffle()
		var troops = []
		var size = options.size()/Global.num.arena.round
		var counter = 0
		
		for _i in Global.num.arena.round:
			troops.append([])
			
			for _j in size:
				troops[_i].append(options[counter])
				counter += 1
		

	func spread_cultivators():
		pass
