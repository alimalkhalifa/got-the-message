extends CanvasLayer

signal tower_selected(name)
signal quit
signal nextlevel
onready var downloadbar = $DownloadProgressContainer/VBoxContainer/DownloadBar
onready var powerlabel = $DownloadProgressContainer/VBoxContainer/PowerLabel
onready var downloadcontainer = $DownloadProgressContainer
onready var victory = $VictoryContainer

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass 

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _on_LaserEmitter_pressed():
	emit_signal("tower_selected", "LaserEmitter")

func _on_LaserReceiver_pressed():
	emit_signal("tower_selected", "LaserReceiver")

func _on_progress( val, power ):
	downloadcontainer.visible = true
	downloadbar.value = val
	powerlabel.text = "Power Used: " + String(floor(power)) + "Kwh"

func _on_victory():
	victory.visible = true

func _on_Quit_pressed():
	emit_signal("quit")

func _on_NextLevel_pressed():
	emit_signal("nextlevel")
