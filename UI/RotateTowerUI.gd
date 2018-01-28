extends CanvasLayer

signal rotate_left
signal rotate_right
signal delete

func _on_Left_pressed():
	emit_signal("rotate_left")

func _on_Right_pressed():
	emit_signal("rotate_right")

func _on_Delete_pressed():
	emit_signal("delete")