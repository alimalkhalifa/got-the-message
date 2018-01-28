extends Node2D

signal progress(val, power)
signal victory

onready var tm = $TileMap
onready var rotateUIScn = preload("res://UI/RotateTowerUI.tscn")
onready var deleteUIScn = preload("res://UI/DeleteTowerUI.tscn")

var towerselected = ""
var widgetUI
var download = false
var progress = 0
var power = 0
var next_loop_full_update = false

export(String) var nextlevel

func _ready():
	_randomize_tiles()

func _process(delta):
	if next_loop_full_update:
		if tm and weakref(tm):
			for tower in tm.get_children():
				if tower is preload("res://Towers/Tower.gd") and not tower is preload("res://Towers/Range/StartTower/StartTower.gd"):
					tower.deactivate()
			update_towers()
	if progress >= 100:
		progress = 100
		emit_signal("progress", progress, power)
		victory()
	elif download:
		progress += delta * 10
		for tower in tm.get_children():
			if tower is preload("res://Towers/Tower.gd"):
				power += tower.power * delta
		emit_signal("progress", progress, power)

func victory():
	emit_signal("victory")

func _draw():
	for tower in tm.get_children():
		if tower is preload("res://Towers/Range/RangeTower.gd"):
			for tile in tower.in_range:
				if tile == Vector2(0,0):
					continue
				draw_rect(Rect2(tile*32 - Vector2(16,16) + tower.position, Vector2(32,32)), Color(1,0,0,0.5), true)
	
	if towerselected != "":
		var mouse = get_global_mouse_position()
		var state = get_world_2d().direct_space_state
		var pos = Vector2(floor((mouse.x) /32) , floor((mouse.y) /32) ) * 32
		var hit = state.intersect_point(pos + Vector2(5, 5))

		if hit.empty():
			var coords = tm.world_to_map(get_global_mouse_position())
			if tm.get_cell(coords.x, coords.y) == 3:
				return
			match towerselected:
				"LaserEmitter":
					draw_texture(preload("res://Towers/Beam/LaserEmitter/LaserEmitter_Icon.png"), pos + Vector2(0, -19))
				"LaserReceiver":
					draw_texture(preload("res://Towers/Range/LaserReceiver/LaserReceiver.png"), pos + Vector2(0, -19))

func _unhandled_input(event):
	if towerselected != "":
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.is_pressed():
				var mouse = get_local_mouse_position()
				var state = get_world_2d().direct_space_state
				var pos = Vector2(floor((mouse.x) /32), floor((mouse.y) /32)) * 32
				var hit = state.intersect_point(pos + Vector2(5,5))
				if hit.empty():
					var coords = tm.world_to_map(get_local_mouse_position())
					if tm.get_cell(coords.x, coords.y) == 3:
						clear_widgetUI()
						return
					var tower
					match towerselected:
						"LaserEmitter":
							tower = preload("res://Towers/Beam/LaserEmitter/LaserEmitter.tscn").instance()
						"LaserReceiver":
							tower = preload("res://Towers/Range/LaserReceiver/LaserReceiver.tscn").instance()
					tower.position = pos + Vector2(16, 16)
					tm.add_child(tower)
					tower.connect("force_update_drawing", self, "_on_force_update_drawing")
					update_towers()
					towerselected = ""
				clear_widgetUI()
			if event.button_index == BUTTON_RIGHT and event.is_pressed():
				towerselected = ""
		#Update drawing
		update()
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.is_pressed() and widgetUI and weakref(widgetUI):
			clear_widgetUI()
		elif event.button_index == BUTTON_LEFT and event.is_pressed():
			var state = get_world_2d().direct_space_state
			var hit = state.intersect_point(get_global_mouse_position(), 32, [], 2)
			if not hit.empty():
				if hit[0].collider is preload("res://Towers/Tower.gd"):
					clear_widgetUI()
				if hit[0].collider is preload("res://Towers/Beam/BeamTower.gd"):
					widgetUI = rotateUIScn.instance()
					widgetUI.connect("rotate_left", hit[0].collider, "rotate_left")
					widgetUI.connect("rotate_right", hit[0].collider, "rotate_right")
					widgetUI.connect("delete", hit[0].collider, "delete")
					widgetUI.connect("delete", self, "clear_widgetUI")
				elif hit[0].collider is preload("res://Towers/Range/RangeTower.gd") and not hit[0].collider is preload("res://Towers/Range/StartTower/StartTower.gd"):
					widgetUI = deleteUIScn.instance()
					widgetUI.connect("delete", hit[0].collider, "delete")
					widgetUI.connect("delete", self, "clear_widgetUI")
				if hit[0].collider is preload("res://Towers/Tower.gd"):
					var pos = hit[0].collider.position + Vector2(-16, 10)
					widgetUI.get_node("Container").set_begin(pos)
					add_child(widgetUI)
			elif widgetUI and weakref(widgetUI):
				clear_widgetUI()

func _randomize_tiles():
	var buildings = [2, 8, 9, 10, 11, 12]
	var houses = [1, 5, 6, 7]
	var tile_rect = tm.get_used_rect()
	for x in range(tile_rect.position.x, tile_rect.position.x + tile_rect.size.x):
		for y in range(tile_rect.position.y, tile_rect.position.y + tile_rect.size.y):
			if tm.get_cell(x, y) == 2:
				tm.set_cell(x, y, buildings[randi()%6])
			elif tm.get_cell(x,y) == 1:
				tm.set_cell(x, y, houses[randi()%4])
	
func _on_UI_tower_selected( name ):
	clear_widgetUI()
	towerselected = name

func clear_widgetUI():
	if widgetUI and weakref(widgetUI):
		widgetUI.queue_free()
		widgetUI = null

func update_towers():
	for tower in tm.get_children():
		if tower is preload("res://Towers/Tower.gd"):
			tower.recalc()


func _on_FinishTower_start_download():
	download = true

func _on_FinishTower_stop_download():
	download = false

func _on_force_update_drawing():
	update()
	next_loop_full_update = true

func _on_UI_nextlevel():
	if nextlevel:
		get_tree().change_scene(nextlevel)
	else:
		print("No next level defined")

func _on_UI_quit():
	get_tree().change_scene("res://MainMenu.tscn")


func _on_StartTower_force_update_drawing():
	pass # replace with function body
