extends Node2D
#==========TODO==========#

#==========Variables==========#
const white : Color = Color(1, 1, 1)
const purple : Color = Color(0.850507, 0.550386, 0.933105)

var current_tab : String = "Main"
var cur_day : int
var cur_date : String
var statistics_tab : int = 0

#==========Onready Variables==========#
onready var main : Node2D = $Main
onready var challenges : Node2D = $Challenges
onready var statistics : Node2D = $Statistics
onready var settings : Node2D = $Settings
onready var credits : Node2D = $Credits
onready var load_menu : Node2D = $LoadMenu
onready var title : Sprite = $Title
onready var novel_label : RichTextLabel = $NovelLabel
onready var main_buttons : Array = [$Main/StoryModeButton, $Main/ChallengeModeButton, $Main/StatisticsMenuButton, $Main/SettingsMenuButton, $Main/QuitButton]
onready var challenge_buttons : Array = [$Challenges/Challenge1Button, $Challenges/Challenge2Button, $Challenges/Challenge3Button, $Challenges/Challenge4Button, $Challenges/Challenge5Button]
onready var other_buttons : Array = [$Challenges/BackButton, $Settings/BackButton, $Statistics/BackButton, $Settings/ResetButton]
onready var salm_slots : Array = [$LoadMenu/Slot1, $LoadMenu/Slot2, $LoadMenu/Slot3, $LoadMenu/Slot4, $LoadMenu/Slot5, $LoadMenu/Slot6, $LoadMenu/Slot7, $LoadMenu/Slot8]
onready var day_label : Label = $DayLabel

#==========Functions==========#
func _ready() -> void:
	switch_tab(current_tab, false)
	for i in range(0, 5):
		main_buttons[i].connect("mouse_entered", self, "change_button_label_color", [main_buttons[i], purple])
		main_buttons[i].connect("mouse_exited", self, "change_button_label_color", [main_buttons[i], white])
		challenge_buttons[i].connect("mouse_entered", self, "change_button_label_color", [challenge_buttons[i], purple])
		challenge_buttons[i].connect("mouse_exited", self, "change_button_label_color", [challenge_buttons[i], white])
	for i in range(0, other_buttons.size()):
		other_buttons[i].connect("mouse_entered", self, "change_button_label_color", [other_buttons[i], purple])
		other_buttons[i].connect("mouse_exited", self, "change_button_label_color", [other_buttons[i], white])
	
	#Connect buttons load menu
	for i in range(0, 8):
		salm_slots[i].connect("pressed", self, "_on_load_progress", [i])
	BackgroundMusic.play_music("Main_Menu")

func switch_tab(tab : String, sfx : bool = true) -> void:
	challenges.hide()
	main.hide()
	statistics.hide()
	settings.hide()
	credits.hide()
	load_menu.hide()
	title.show()
	novel_label.show()
	day_label.show()
	current_tab = tab
	
	if sfx:
		Global.play_sfx("Select")
	
	if tab == "Main":
		cur_date = Time.get_date_string_from_system()
		cur_day = Global.get_total_day_and_session_time().cur_day
		day_label.text = cur_date.replace("-", "/") + ", DAY " + String(cur_day)
		if cur_day <= 7:
			if !Global.user_data["DataSent"][cur_day-1]:
				day_label.text += " - IN PROGRESS"
			else:
				day_label.text += " - DONE"
		main.show()
	elif tab == "Challenges":
		if !Global.user_data["ChallengesUnlocked"]:
			cur_date = Time.get_date_string_from_system()
			var total_day_and_time = Global.get_total_day_and_session_time(cur_date)
			if total_day_and_time.story_time >= Data.STORY_MODE_COLLECTION_TIME:
				Global.user_data["ChallengesUnlocked"] = true
				Global.save_user_data()
		
		if !Global.user_data["ChallengesUnlocked"]:
			main.show()
			Global.create_popup("CHALLENGES ARE LOCKED: PLEASE FINISH 5 MINS IN THE STORY MODE FIRST", self)
		else:
			challenges.show()
	elif tab == "Statistics":
		title.hide()
		novel_label.hide()
		day_label.hide()
		
		var data_left = ""
		var data_right = ""
		var stats = Global.get_stats()
		
		if statistics_tab == 0:
			data_left = "OVERALL WPM: " + String(round(stats.OverallWPM)) + "\nOVERALL ACCURACY: " + String(round(stats.OverallAccuracy * 100)) + "\n\nSTORY WPM: " + String(round(stats.StoryWPM)) + "\nSTORY ACCURACY: " + String(round(stats.StoryAccuracy * 100)) + "\n\nTOTAL TIME: " + String(stats.PlayTime / 60).pad_decimals(1) + " MINS\nTYPING TIME: " + String(stats.TypingTime / 60).pad_decimals(1) + " MINS"
			data_right = "CHALLENGE STATS\n(#, WPM, ACC, COUNT)\n"
			for i in range(0, 5):
				var x = stats["ChallengeStats" + String(i+1)]
				data_right += String(i+1) + " - " + String(round(x[0])) + ", " + String(round(x[1])) + "%, " + String(x[2])
				if i < 4:
					data_right += "\n"
		elif statistics_tab == 1:
			var diff_letters = Global.get_difficulty_letters()
			data_left = "DIFFICULT LETTERS:\n"
			if diff_letters.size() > 0:
				for i in range(0, diff_letters.size()):
					data_left += diff_letters[i].to_upper() + ", "
				data_left.erase(data_left.length() - 2, 2)
			else:
				data_left += "NONE"
			
			var mastered_words = Global.get_mastered_words()
			data_right = "MASTERED WORDS:\n"
			if mastered_words.size() > 0:
				for i in range(0, mastered_words.size()):
					data_right += mastered_words[i] + ", "
				data_right.erase(data_right.length() - 2, 2)
			else:
				data_right += "NONE"
		
		statistics.get_node("StatsLabelLeft").parse_bbcode("[center]" + data_left + "[/center]")
		statistics.get_node("StatsLabelRight").parse_bbcode("[center]" + data_right + "[/center]")
		statistics.show()
	elif tab == "Settings":
		title.hide()
		novel_label.hide()
		day_label.hide()
		settings.get_node("BGMSlide").value = Global.user_data["Music"]
		settings.get_node("SFXSlide").value = Global.user_data["Sfx"]
		settings.get_node("FSCheckBox").pressed = Global.user_data["Fullscreen"]
		settings.show()
	elif tab == "Credits":
		main.show()
		Global.switch_scene("Credits")
	elif tab == "LoadMenu":
		title.hide()
		novel_label.hide()
		day_label.hide()
		for i in range(0, 8):
			if Global.user_data["SavedProgress"][i].size() <= 0:
				salm_slots[i].text = "EMPTY"
				salm_slots[i].get_node("Text").text = ""
			else:
				if Global.user_data["SavedProgress"][i].has("image_path"):
					salm_slots[i].icon = load(Global.user_data["SavedProgress"][i]["image_path"])
				salm_slots[i].text = ""
				salm_slots[i].get_node("Text").text = Global.user_data["SavedProgress"][i]["scene"] + ": " + Global.user_data["SavedProgress"][i]["save_date"]
		load_menu.show()
		
	#To fix visual upon changing menus
	for i in range(0, 5):
		change_button_label_color(main_buttons[i], white)
	for i in range(0, other_buttons.size()):
		change_button_label_color(other_buttons[i], white)

func change_button_label_color(button, color) -> void:
	button.get_node("Label").set("custom_colors/font_color", color)

#==========Connected Functions==========#
#=====Main Menu Functions=====#
func _on_StoryModeButton_pressed():
	if Global.has_saved_story_data():
		Global.play_sfx("Select")
		Global.create_yes_no_popup("SAVED FILE FOUND! dO YOU WANT TO OPEN THE LOAD MENU?", self, "_on_yes_popup", "_on_no_popup")
	else:
		Global.play_sfx("Confirm")
		Global.switch_scene("StoryMode")

func _on_yes_popup():
	switch_tab("LoadMenu", false)

func _on_no_popup():
	Global.play_sfx("Confirm")
	Global.switch_scene("StoryMode")

func _on_ChallengeModeButton_pressed():
	switch_tab("Challenges")

func _on_StatisticsMenuButton_pressed():
	switch_tab("Statistics")

func _on_NextBtn_pressed():
	statistics_tab = 1
	switch_tab("Statistics")
	statistics.get_node("NextBtn").hide()
	statistics.get_node("PrevBtn").show()

func _on_PrevBtn_pressed():
	statistics_tab = 0
	switch_tab("Statistics")
	statistics.get_node("NextBtn").show()
	statistics.get_node("PrevBtn").hide()

func _on_SettingsMenuButton_pressed():
	switch_tab("Settings")

func _on_BGMSlide_value_changed(value):
	BackgroundMusic.volume_db = value
	Global.user_data["Music"] = value

func _on_SFXSlide_drag_ended(value_changed : bool):
	Global.user_data["Sfx"] = settings.get_node("SFXSlide").value
	Global.play_sfx("Confirm")

func _on_ResetButton_pressed():
	Global.create_yes_no_popup("ARE YOU SURE YOU WANT TO RESET DATA?", self, "_on_reset_data")
	Global.play_sfx("Bright")

func _on_reset_data():
	settings.get_node("SFXSlide").value = -20
	settings.get_node("BGMSlide").value = -25
	BackgroundMusic.volume_db = -25
	Global.delete_user_data()
	BackgroundMusic.stop_music(true)
	Global.switch_scene("IDInput")

func _on_CreditsButton_pressed():
	switch_tab("Credits")

func check_if_possible_to_send_data() -> bool:
	var total_day_and_time : Dictionary = Global.get_total_day_and_session_time(cur_date)
	if total_day_and_time.challenge_time >= Data.CHALLENGE_MODE_COLLECTION_TIME and total_day_and_time.story_time >= Data.STORY_MODE_COLLECTION_TIME and total_day_and_time.cur_day == 6:
		return true
	return false
		
func _on_SendDataButton_pressed():
	if cur_day == 1:
		if !Global.user_data["DataSent"][0]:
			Global.create_popup("Data will be automatically sent to us after finishing 10 mins in story mode", self)
		else:
			Global.create_popup("Data has already been sent for this day", self)
	elif cur_day == 6:
		if !check_if_possible_to_send_data():
			Global.create_popup("5 mins requirement in Story or Challenge mode are still not yet finished", self)
		elif !Global.user_data["DataSent"][1]:
			Global.create_yes_no_popup("Are you sure you want to send your data for this day?", self, "_send_test_data")
		else:
			Global.create_popup("Data has already been sent for this day", self)
	elif cur_day == 7:
		if !Global.user_data["DataSent"][2]:
			Global.create_popup("Data will be automatically sent to us after finishing 5 mins in Story and Challenge mode.", self)
		#elif !Global.user_data["DataSent"][2]:
			#Global.create_yes_no_popup("Are you sure you want to send your data for this day?", self, "_send_post_test_data")
		else:
			Global.create_popup("Data has already been sent for this day", self)
	else:
		Global.create_popup("There is no need to send data for this day", self)
	Global.play_sfx("Bright")

#FIX HERE (STORY AND CHALLENGE MODE), CHECK ALSO IN POST TEST
func _send_test_data() -> void:
	#var cur_stats = Global.get_stats_on_date(cur_date)
	#Send to google forms
	#var user_data_mod = Global.user_data.duplicate(true)
	#user_data_mod.erase("WordMastery")
	#Global.send_data("TEST", Global.user_data.SchoolID, cur_date, cur_stats.OverallWPM, cur_stats.OverallAccuracy, JSON.print(user_data_mod, "\t"))
	#Global.save_user_data()
	return
	
func _on_load_progress(index : int):
	if Global.user_data["SavedProgress"][index].size() <= 0:
		return
	Global.load_slot_index_selected = index
	Global.switch_scene("StoryMode")
	Global.play_sfx("Confirm")

func _on_QuitButton_pressed():
	Global.create_yes_no_popup("Are you sure you want to quit?", self, "_quit_game")
	Global.play_sfx("Bright")
	
func _quit_game() -> void:
	get_tree().quit()
	
#=====Challenges Functions=====#
func _on_Challenge1Button_pressed():
	Global.switch_scene("Challenge1")
	Global.play_sfx("Confirm")

func _on_Challenge1Button2_pressed():
	Global.switch_scene("Challenge2")
	Global.play_sfx("Confirm")

func _on_Challenge1Button3_pressed():
	Global.switch_scene("Challenge3")
	Global.play_sfx("Confirm")

func _on_Challenge1Button4_pressed():
	Global.switch_scene("Challenge4")
	Global.play_sfx("Confirm")

func _on_Challenge1Button5_pressed():
	Global.switch_scene("Challenge5")
	Global.play_sfx("Confirm")

func _on_BackButton_pressed():
	switch_tab("Main")
	Global.save_user_data()

func _on_HideSalmMenu_pressed():
	switch_tab("Main")

func _on_FSCheckBox_toggled(button_pressed):
	Global.user_data["Fullscreen"] = button_pressed
	OS.window_fullscreen = button_pressed
