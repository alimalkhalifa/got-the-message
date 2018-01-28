extends StaticBody2D

signal force_update_drawing
var active = false
const power = 500
func _ready():
	pass

func _get_tile_pos():
	return Vector2(floor(position.x / 32), floor(position.y / 32))
	
func activate():
	active = true
	pass

func deactivate():
	active = false
	pass
	
func recalc():
	pass

func delete():
	queue_free()
	call_deferred("emit_signal", "force_update_drawing")