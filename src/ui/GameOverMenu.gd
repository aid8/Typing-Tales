extends CanvasLayer
#==========TODO==========#
#Popup if time is already 10 mins in global, check (if this is 6th or 7th day as well)

#==========Onready Variables==========#
onready var stats_label = $StatsLabel

#==========Functions==========#
func _ready():
	pass # Replace with function body.

func init(stats : String) -> void:
	stats_label.text = stats
	#Popup here 10 mins

func _on_RestartButton_pressed():
	get_tree().paused = false
	SceneTransition.switch_scene(String(get_tree().current_scene.filename), "Curtain")

func _on_MainMenuButton_pressed():
	get_tree().paused = false
	#TODO: Add current session time here
	Global.switch_scene("MainMenu")
