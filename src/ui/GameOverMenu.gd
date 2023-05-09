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
	#check_time()

#CHANGE HERE AS WELL
#func check_time() -> void:
#	var cur_date : String = Time.get_date_string_from_system()
#	var total_day_and_time : Dictionary = Global.get_total_day_and_session_time(cur_date)
#	if total_day_and_time.cur_day <= 3:
#		if total_day_and_time.challenge_time >= Data.CHALLENGE_MODE_COLLECTION_TIME:
#			if total_day_and_time.story_time >= Data.STORY_MODE_COLLECTION_TIME:
#				if Global.user_data["DataSent"][total_day_and_time.cur_day-1]:
#					return
#				#Autosend data
#				var cur_stats = Global.get_stats_on_date(cur_date)
#				var user_data_mod = Global.user_data.duplicate(true)
#				user_data_mod.erase("WordMastery")
#				Global.send_data(total_day_and_time.cur_day, Global.user_data.SchoolID, cur_date, cur_stats.OverallWPM, cur_stats.OverallAccuracy, JSON.print(user_data_mod))
#				note_label.text = "Requirements for the day are done. Data has been automatically sent to us."
#				if total_day_and_time.cur_day == 3:
#					note_label.text += " Proceed to Final WPM test."
#			else:
#				note_label.text = "5 mins requirement for challenge mode is done. You still need to play the story mode"
#		else:
#			note_label.text = Global.format_time(Data.CHALLENGE_MODE_COLLECTION_TIME - total_day_and_time.challenge_time) + " MINS Left to meet the requirements for challenge mode"
#		note_label.show()

func _on_RestartButton_pressed():
	get_tree().paused = false
	Global.play_sfx("Select")
	SceneTransition.switch_scene(String(get_tree().current_scene.filename), "Curtain")

func _on_MainMenuButton_pressed():
	get_tree().paused = false
	Global.play_sfx("Select")
	Global.switch_scene("MainMenu")
