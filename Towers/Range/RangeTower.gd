extends "res://Towers/Tower.gd"

const signal_range = 0

var Direction = {
	"NORTH": Vector2(0,-1),
	"SOUTH": Vector2(0,1),
	"EAST": Vector2(-1,0),
	"WEST": Vector2(1,0)
}

var in_range = []

func _ready():
	pass

func recalc():
	in_range = _calc_in_range()

func _calc_in_range():
	if not active:
		return []
	
	var queue = [{
		"pos": Vector2(0,0),
		"cost": 0
	}]
	var done = []
	
	while not queue.empty():
		var current = queue.pop_front()
		var pos = current.pos
		for d in Direction:
			var newpos = pos + Direction[d]
			if current.cost + 1 < signal_range and not _is_in_queue_or_done(newpos, queue, done):
				if _signal_receiver_tower(newpos):
					var tower = _signal_receiver_tower(newpos)
					if tower is preload("res://Towers/Tower.gd") and not tower is get_script():
						tower.activate()
				elif not _signal_collides(newpos):
					queue.push_back({
						"pos": newpos,
						"cost": current.cost + 1
					})
				elif _signal_collides_house(newpos):
					queue.push_back({
						"pos": newpos,
						"cost": current.cost + 1
					})
		done.push_back(current)
	
	var in_range = []
	for d in done:
		in_range.push_back(d.pos)
	return in_range

func _signal_collides(pos):
	pos = (pos * 32) + global_position
	var state = get_world_2d().direct_space_state
	var hit = state.intersect_point(pos,32,[],1)
	return not hit.empty()

func _signal_collides_house(pos):
	pos = (pos * 32) + global_position
	var state = get_world_2d().direct_space_state
	var hit = state.intersect_point(pos,32,[],1)
	if not hit.empty():
		if hit[0].collider.get_name() == "TileMap":
			var tm = hit[0].collider
			var mpos = tm.world_to_map(pos)
			var tile = tm.get_cell(mpos.x, mpos.y)
			if [1, 5, 6, 7].find(tile) >= 0:
				return true
	return false

func _signal_receiver_tower(pos):
	pos = (pos * 32) + global_position
	var state = get_world_2d().direct_space_state
	var hit = state.intersect_point(pos,32,[],2)
	if not hit.empty():
		return hit[0].collider

func _is_in_queue_or_done(pos, queue, done):
	for q in queue:
		if pos == q.pos:
			return true
	for d in done:
		if pos == d.pos:
			return true
	return false

func activate():
	.activate()

	active = true
	recalc()

func deactivate():
	active = false
	recalc()
	emit_signal("force_update_drawing")
	.deactivate()

# Might be easier to do this with just running all rangetower logics again, and when they find a tower on a tile they trigger (see up)
###Skas: Adding Stuffs
#func _check_for_nearby_towers():
#	#Check for nearyby towers
#	#Choose the one with a direct line of sight
#	var state = get_world_2d().direct_space_state
#	var tile_map = get_parent()
#
#	var closest_tower = null
#	var smallest_distance = null
#	for child in tile_map.get_children():
#		if child is preload("res://Towers/Tower.gd") and child != self:
#			var dist = Vector2(closest_tower.position - self.position).length
#			if(dist < smallest_distance or dist == null):
#				smallest_distance = dist
#				closest_tower = child
#
#	print("Closest tower is at "+smallest_distance)

			

