extends "res://Towers/Range/RangeTower.gd"


const signal_range = 3

func _ready():
	activate()

func _on_victory():
	deactivate()
