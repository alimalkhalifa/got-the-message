extends "res://Towers/Tower.gd"

onready var laserScn = preload("res://Laser/Laser.tscn")
onready var sprite = $Sprite

var laser
var laser_rotation = 0
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func activate():
	if laser and weakref(laser):
		return
	laser = laserScn.instance()
	laser.position = position
	laser.parents.push_back(self)
	laser.z_index = 1
	laser.rotation = laser_rotation
	get_parent().add_child(laser)

func recalc():
	if laser and weakref(laser):
		laser.recalc()

func deactivate():
	if laser and weakref(laser):
		laser_rotation = laser.rotation
		laser.queue_free()
		laser = null

func rotate_left():
	if laser and weakref(laser):
		laser.rotation -= deg2rad(45)
		laser.recalc()
	if sprite.frame == 7:
		sprite.frame = 0
	else:
		sprite.frame += 1

func rotate_right():
	if laser and weakref(laser):
		laser.rotation += deg2rad(45)
		laser.recalc()
	if sprite.frame == 0:
		sprite.frame = 7
	else:
		sprite.frame -= 1

func delete():
	if laser and weakref(laser):
		laser.queue_free()
	.delete()