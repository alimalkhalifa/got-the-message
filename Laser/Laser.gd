extends Node2D


onready var sprite = $Sprite

const SPRITESPEED = 512

var parents = []

func _ready():
	recalc()
	get_node("Laser_Activate").stream.set_loop(false)
	pass

func _process(delta):
	sprite.region_rect.position.x -= delta * SPRITESPEED
	if sprite.region_rect.position.x < -64:
		sprite.region_rect.position.x = 0
	
	
	
	#Skas: These increase the size of the ray 
#	sprite.region_rect.size.x += 5
#	sprite.offset.x += 5/2.0

#func _draw():
#	var to = Vector2(1,0)
#	to = to.rotated(rotation)
#	var state = get_world_2d().direct_space_state
#	var hit = state.intersect_ray(position, position + (to * 1000))
#	draw_line(Vector2(0,0), to*1000, Color(1,0,0), 5)
#	if not hit.empty():
#		draw_circle(hit.position - position, 8, Color(0,1,0))

func recalc():
	var to = Vector2(1,0).rotated(rotation)
	sprite.position = Vector2(20 - sin(rotation) * 20 , cos(rotation) * -20)
	#to = to.rotated(rotation)
	
	var state = get_world_2d().direct_space_state
	var hit = state.intersect_ray(position, position + (to * 1000), parents)
	var magnitude
	if not hit.empty():
		magnitude = (hit.position - position).length() - 20
		if hit.collider is preload("res://Towers/Range/LaserReceiver/LaserReceiver.gd"):
			hit.collider.activate()
	else:
		magnitude = 1000
	sprite.region_rect = Rect2(0, 0, magnitude, 32)
	sprite.offset = Vector2(magnitude/2, 0)


