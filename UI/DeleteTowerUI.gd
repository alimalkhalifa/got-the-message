extends CanvasLayer

signal delete

func _on_Delete_pressed():
	emit_signal("delete")