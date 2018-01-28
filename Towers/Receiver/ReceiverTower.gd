extends "res://Towers/Tower.gd"

signal start_download
signal stop_download

func _ready():
	pass

func activate():
	emit_signal("start_download")

func deactivate():
	emit_signal("stop_download")
