extends CanvasLayer
#==========TODO==========#
#Popup if time is already 10 mins in global, check (if this is 6th or 7th day as well)

#==========Onready Variables==========#
onready var stats_label = $StatsLabel
onready var note_label = $NoteLabel

#==========Functions==========#
func _ready():
	pass # Replace with function body.

func init(stats : String) -> void:
	stats_label.text = stats
	check_time()

func check_time() -> void:
	var cur_date : String = Time.get_date_string_from_system()
	var total_day_and_time : Dictionary = Global.get_total_day_and_session_time(cur_date)
	if total_day_and_time.time >= Data.TOTAL_COLLECTION_TIME and (total_day_and_time.cur_day == 6 or total_day_and_time.cur_day == 7):
		note_label.show()

func _on_RestartButton_pressed():
	get_tree().paused = false
	Global.play_sfx("Select")
	SceneTransition.switch_scene(String(get_tree().current_scene.filename), "Curtain")

func _on_MainMenuButton_pressed():
	get_tree().paused = false
	Global.play_sfx("Select")
	Global.switch_scene("MainMenu")
