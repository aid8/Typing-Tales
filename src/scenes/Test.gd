extends Node2D
#==========TODO==========#

#==========NOTES==========#
#Codes that have #TESTING should be rechecked when testing is done (ready to deploy)

#==========Testing Stuffs==========#
onready var testbox = $TestBox
var debug_mode = true

func _on_TestBox_confirmed():
	Global.load_user_data()
	#load_saved_progress()
	get_current_dialogue()
	ui.show()

func _on_TestBtn_pressed():
	get_tree().reload_current_scene()

func _on_ClearButton_pressed():
	#Delete data and Reload current scene
	Global.delete_user_data()
	get_tree().reload_current_scene()
	
func cancelled():
	get_current_dialogue()
	ui.show()

#==========Variables==========#
const white : Color = Color("#FFFFFF")
const red : Color = Color("#FF0000")
const green : Color = Color("#90EE90")
const yellow : Color = Color("#FFFF80")
const light_blue : Color = Color("#ADD8E6")
const light_gray : Color = Color("#D3D3D3")
const light_orange : Color = Color("#FFD580")

var current_scene : String = "Chapter 1" #"Test"
var current_scene_index: int = 0
var current_letter_index : int = 0
var current_location : String = ""
var wrong_letter_length : int = 0
var current_dialogue : String = ""
var current_dialogue_remark : String = ""
var dialogue_space : bool = false
var typing_target : String = "dialogue" #dialogue or choice
var choosing_selection : bool = false
var chosen_selection : Node2D = null
var	choice_selections : Array = []
var character_dict : Dictionary = {}
var typed_word_accuracy : Dictionary = {}
var current_word_index : int = 0
var mastered_word_indices : Dictionary = {} #{start : length}
var mastered_words : Dictionary = {} #{word : true}
var has_choice_timer : bool = false
var ignore_typing : bool = false
var current_wpm : float = 0
var total_time : float = 0
var tracing_wpm : bool = false
var skipped_characters_length : int = 0 #for accurate wpm computation, skipped characters should be taken note of
var skip_dialogue : bool = false
var total_wpm : Array = [0, 0] #[total_wpm, count]
var total_accuracy : Array = [0, 0] #[correct_count, wrong_count]
var chapter_play_time : float = 0
var save_slot_index : int = 0
var tutorial_index : int = 0
var current_date : String = ""
var current_session_time : float = 0
var post_test_session_time : float = 0
var is_pre_test : bool = false
var is_post_test : bool = false
var pre_test_done : bool = false

#Scene animation variables
var shake_strength : float = 0.0
var shake_decay : float = 0.0
var history_text_storage : String = ""
#var new_progress : bool = true#if false, this will load the saved progress instead of a new one
var user_time_informed : bool = false
var last_choice_index : int = 0
var saved_info_for_branching : Dictionary

#==========Onready Variables==========#
onready var rand = RandomNumberGenerator.new()
onready var camera : Camera2D = $Camera
onready var ui : CanvasLayer = $UI
onready var characters : Node2D = $Characters
onready var backgrounds : AnimatedSprite = $Backgrounds
onready var character_name : RichTextLabel = $UI/CharacterName
onready var dialogue : RichTextLabel = $UI/Dialogue
onready var type_box :RichTextLabel = $UI/TypeBox
onready var type_box_background : Sprite = $UI/TypeBoxBackground
onready var choice_selection_position : Position2D = $UI/ChoiceSelectionPosition
onready var character_positions : Dictionary = {
	"LEFT" : $Characters/CharacterLeftPosition,
	"MIDDLE" : $Characters/CharacterMidPosition,
	"RIGHT" : $Characters/CharacterRightPosition,
}
onready var choice_timer : Timer = $ChoiceTimer
onready var testing_timer : Timer = $TestingTimer
onready var idle_timer : Timer = $IdleTimer
onready var timer_pop_up : AcceptDialog = $UI/TimerPopUp
onready var timer_node : Node2D = $UI/TimerNode
onready var timer_label : Label = $UI/TimerNode/TimerLabel
onready var wpm_label : Label = $UI/WPMLabel
onready var space_label : Label = $UI/SpaceLabel
onready var history_menu : Node2D = $UI/HistoryMenu
onready var history_text : RichTextLabel = $UI/HistoryMenu/HistoryText
onready var stats_menu : Node2D = $UI/StatsMenu
onready var name_menu : Node2D = $UI/NameMenu
onready var name_edit : LineEdit = $UI/NameMenu/NameEdit
onready var intro_menu : Node2D = $UI/IntroMenu
onready var intro_label : Label = $UI/IntroMenu/IntroLabel
onready var save_and_load_menu : Node2D = $UI/SaveAndLoadMenu
onready var salm_slots : Array = [$UI/SaveAndLoadMenu/Slot1, $UI/SaveAndLoadMenu/Slot2, $UI/SaveAndLoadMenu/Slot3, $UI/SaveAndLoadMenu/Slot4, $UI/SaveAndLoadMenu/Slot5, $UI/SaveAndLoadMenu/Slot6, $UI/SaveAndLoadMenu/Slot7, $UI/SaveAndLoadMenu/Slot8]
onready var salm_title_label : Label = $UI/SaveAndLoadMenu/TitleLabel
onready var save_confirmation_popup : ConfirmationDialog = $UI/SaveConfirmationPopUp
onready var tutorial_menu : Node2D = $UI/TutorialMenu
onready var tutorial_images : AnimatedSprite = $UI/TutorialMenu/TutorialImages
onready var tutorial_title_label : Label = $UI/TutorialMenu/TitleLabel
onready var pause_menu : Node2D = $UI/PauseMenu
onready var http_request : HTTPRequest = $HTTPRequest
onready var time_menu : AcceptDialog = $UI/TimeMenu
onready var bad_end_menu : Node2D = $UI/BadEndMenu

#==========Preload Variables==========#
onready var choice_selection = preload("res://src/ui/ChoiceSelection.tscn")
onready var character = preload("res://src/objects/Character.tscn")

#==========Functions==========#
func _ready() -> void:
	rand.randomize()
	#TESTING
	# if not Global.check_first_time():
	#	ui.hide()
	#	testbox.connect("modal_closed", self, "cancelled")
	#	testbox.get_close_button().connect("pressed", self, "cancelled")
	#	testbox.get_cancel().connect("pressed", self, "cancelled")
	#	testbox.popup()
	#	return
	
	#TESTING
	if !Global.user_data["SeenTutorials"][5]:
		name_menu.show() #get name for the first time
		tutorial_menu.show()
		Global.user_data["SeenTutorials"][5] = true
		Global.save_user_data()
	
	#Setup tracing of data for research (only for 1st, 6th and 7th day)
	#TESTING
	current_date = Time.get_date_string_from_system()
	if !Global.user_data["SavedDataResearch"]["StoryMode"].has(current_date) or !Global.user_data["DataSent"][0]:
		Global.setup_research_variables("StoryMode", current_date)
		var cur_size = Global.get_total_day_and_session_time(current_date).cur_day
		if cur_size == 1:
			print("Starting Pretest")
			is_pre_test = true
			pre_test_done = false
			if !debug_mode:
				testing_timer.wait_time = Data.TOTAL_COLLECTION_TIME
				testing_timer.one_shot = true
				testing_timer.start()
			idle_timer.wait_time = Data.IDLE_TIME
			idle_timer.start()
		elif cur_size == 6 or cur_size == 7:
			is_post_test = true
			idle_timer.wait_time = Data.IDLE_TIME
			idle_timer.start()
	
	if Global.load_slot_index_selected != -1:
		load_saved_progress(Global.load_slot_index_selected, false)
		Global.load_slot_index_selected = -1
	else:
		get_current_dialogue()
	history_text.set_scroll_follow(true)
	SceneTransition.connect("transition_finished", self, "on_scene_transition_finished")
	
	#Connect buttons in save and load menu
	for i in range(0, 8):
		salm_slots[i].connect("pressed", self, "_on_save_or_load_progress", [i])

func _process(delta : float) -> void:
	#In charge of choice timer
	if has_choice_timer:
		timer_label.text = String(choice_timer.time_left).pad_decimals(2)
	#In charge of tracing wpm
	if tracing_wpm:
		total_time += delta
	handle_scene_animation(delta)
	handle_variable_tracing(delta)
	
	#RECHECK/TESTING
	if not stats_menu.visible:
		chapter_play_time += delta

func handle_scene_animation(delta : float) -> void:
	#shake anim
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0, shake_decay * delta)
		var rand_off = rand.randf_range(-shake_strength, shake_strength)
		camera.offset = Vector2(rand_off, rand_off)
		if floor(shake_strength) == 0:
			camera.offset = Vector2.ZERO
			shake_strength = 0

func handle_variable_tracing(delta : float) -> void:
	if !idle_timer.is_stopped() and is_post_test:
		post_test_session_time += delta
	current_session_time += delta

#Loads necessary characters, location and scene
func load_saved_progress(index, has_transition : bool = true):
	if has_transition:
		SceneTransition.add_transition("DiamondTilesCover")
		yield(SceneTransition, "transition_finished")
	
	var data = Global.user_data["SavedProgress"][index]
	set_next_scene(data.scene, data.scene_index, false)
	for c in data.characters:
		add_character(c.name, c.outfit, c.expression, c.position)
		if c.is_hidden:
			toggle_character(c.name, true)
	current_location = data.location
	change_background(current_location, data.location_tint)
	get_current_dialogue(false)
	if data.has("bgm"):
		BackgroundMusic.play_music(data.bgm)
	save_and_load_menu.hide()

#Creates a character array and puts all info about the characters present
#Then also saves scene info
func save_progress(index : int):
	var char_array : Array = []
	for c in character_dict.values():
		var char_info : Dictionary = {}
		char_info["name"] = c.character_name
		char_info["outfit"] = c.current_outfit
		char_info["expression"] = c.current_expression
		char_info["position"] = c.current_position
		char_info["is_hidden"] = c.is_hidden
		char_array.append(char_info)
	Global.add_user_data_story_progress(current_scene, current_scene_index, char_array, current_location, "#" + backgrounds.self_modulate.to_html(false), Time.get_datetime_string_from_system(), backgrounds.frames.get_frame(backgrounds.animation, backgrounds.frame).resource_path, BackgroundMusic.current_music, index)
	Global.save_user_data()
	print("Progress is saved!")
	show_save_and_load_menu("save")

#Adds a character sprite on the screen
func add_character(name : String, outfit : String, expression : String, char_position: String):
	var c = character.instance()
	c.initialize(name, outfit, expression, char_position)
	c.position = character_positions[char_position].position
	characters.add_child(c)
	character_dict[name] = c
	
#Deletes all character
func remove_characters(has_fade : bool = true):
	for c in character_dict.values():
		c.remove_character(has_fade)
	character_dict = {}

#Shows/Hides the character depending on passed boolean (hidden)
func toggle_character(name : String, hidden : bool, instant : bool = false):
	if character_dict.has(name):
		character_dict[name].toggle_character(hidden, false, instant)

#Changes the outfit/expression of the character, if parameter is blank, it will be ignored
func modify_character(name : String, outfit : String = "", expression : String = "", char_position : String = ""):
	if outfit != "":
		character_dict[name].change_outfit(outfit)
	if expression != "":
		character_dict[name].change_expression(expression)
	if char_position != "":
		character_dict[name].position = character_positions[char_position].position

#in charge of changing backgrounds and tint
func change_background(location : String = "", location_tint : String = ""):
	if location != "":
		backgrounds.animation = Data.backgrounds[location].Animation
		backgrounds.frame = Data.backgrounds[location].Frame
	if location_tint != "":
		backgrounds.self_modulate = Color(location_tint)

#scene animations
func apply_scene_animation(values : Dictionary) -> void:
	if values.animation == "shake":
		shake_strength = values.shake_strength
		shake_decay = values.shake_decay

#Incharge of displaying selections
func show_selection(selections : Array) -> void:
	choosing_selection = true
	skip_dialogue = false
	last_choice_index = current_scene_index
	
	#Quick save
	var char_array : Array = []
	for c in character_dict.values():
		var char_info : Dictionary = {}
		char_info["name"] = c.character_name
		char_info["outfit"] = c.current_outfit
		char_info["expression"] = c.current_expression
		char_info["position"] = c.current_position
		char_info["is_hidden"] = c.is_hidden
		char_array.append(char_info)
	saved_info_for_branching["characters"] = char_array
	saved_info_for_branching["bgm"] = BackgroundMusic.current_music
	#saved_info_for_branching["background"] = backgrounds.frames.get_frame(backgrounds.animation, backgrounds.frame).resource_path
	saved_info_for_branching["tint"] = "#" + backgrounds.self_modulate.to_html(false)
	saved_info_for_branching["location"] = current_location
	
	for i in range (0, selections.size()):
		var cs = choice_selection.instance()
		cs.next_scene_name = selections[i][1]
		cs.next_scene_index = selections[i][2]
		
		# -1 indicates next dialogue
		if cs.next_scene_index == -1:
			cs.next_scene_index = current_scene_index+1
		
		cs.position = choice_selection_position.position
		cs.position.y += (50 * i)
		choice_selections.append(cs)
		ui.add_child(cs)
		cs.set_choice_text(selections[i][0])
		print(Global.user_data["FinishedScenes"])
		if Global.check_if_scene_is_finished(selections[i][1]):
			cs.set_background("done")

#Incharge of selection ttimer
func set_selection_timer(type : String, time : float = 0) -> void:
	if type == "start":
		choice_timer.start(time)
		timer_node.show()
		has_choice_timer = true
	elif type == "stop":
		choice_timer.stop()
		timer_node.hide()
		has_choice_timer = false

#Incharge of editing, updating TypeBox
#Also adds word mastery
func update_typebox(type : String, letter : String = '') -> void:
	if skip_dialogue or ignore_typing:
		return
	if type == "delete":
		var s = type_box.text
		if s.length() > 0:
			s.erase(s.length() - 1, 1)
			type_box.parse_bbcode("[right]" + s + "[/right]")
			current_word_index -= 1
			check_word_mastery("force_wrong")
	elif type == "add":
		if current_letter_index >= current_dialogue.length():
			return
		if letter == " " and wrong_letter_length == 0 and current_dialogue[current_letter_index] == " ":
			check_word_mastery("add")
			type_box.text = ""
			check_word_mastery("reset")
		else:
			type_box.text += letter
			type_box.parse_bbcode("[right]" + type_box.text + "[/right]")
			check_word_mastery("check")
			current_word_index += 1
	elif type == "reset":
		type_box.text = ""
		check_word_mastery("reset")

#checks if the letters typed are correct, once wrong or backspaced it will be incorrect
#has also the ability to check the accuracy and add it to user data if type is "add"
func check_word_mastery(type : String):
	if type == "check":
		if typed_word_accuracy.has(current_word_index) and not typed_word_accuracy[current_word_index]:
			return
		if type_box.text[current_word_index] != current_dialogue[current_letter_index]:
			typed_word_accuracy[current_word_index] = false
		else:
			typed_word_accuracy[current_word_index] = true
	elif type == "force_wrong":
		typed_word_accuracy[current_word_index] = false
	elif type == "force_correct":
		typed_word_accuracy[current_word_index] = true
	elif type == "add":
		if typed_word_accuracy.size() <= 0:
			return
		var word_accuracy : float = typed_word_accuracy.values().count(true) / float(typed_word_accuracy.size())
		#Add letter mastery
		for i in range(type_box.text.length()):
			Global.add_letter_mastery(type_box.text[i], typed_word_accuracy[i])
			if not Data.unnecessary_characters.has(type_box.text[i]):
				if typed_word_accuracy[i]:
					total_accuracy[0] += 1
				else:
					total_accuracy[1] += 1
		#Add word mastery
		Global.add_word_mastery(type_box.text, word_accuracy)
		
	elif type == "reset":
		current_word_index = 0
		typed_word_accuracy = {}

#Gets and sets the current dialogue and and calls show_colored_dialogue()
func get_current_dialogue(include_transition : bool = true) -> void:
	var dialogue_data = Data.dialogues[current_scene][current_scene_index]
	var has_transition = false
	
	#If dialogue has transition, do that first then wait for it to emit a signal
	if dialogue_data.has("transition") and include_transition:
		has_transition = true
		SceneTransition.add_transition(dialogue_data.transition)
		ignore_typing = true
		yield(SceneTransition, "transition_finished")
		ignore_typing = false
	
	#If dialogue is final end, goto credits
	if dialogue_data.has("game_end"):
		Global.switch_scene("Credits")
		return
	
	#If dialouge has goto_chapter, do this and return
	if dialogue_data.has("goto_chapter"):
		var chap_data = dialogue_data.goto_chapter
		if chap_data[1] == -1:
			chap_data[1] = last_choice_index
			set_next_scene(chap_data[0], chap_data[1], true, false)
		else:
			set_next_scene(chap_data[0], chap_data[1], true, false)
		return
	
	#Show intro menu in start of new chapter
	if current_scene_index == 0 and Global.load_slot_index_selected == -1:
		show_intro_menu(1)
	else:
		if dialogue_data.has("bgm"):
			if dialogue_data.bgm == "STOP":
				BackgroundMusic.stop_music(false)
			else:
				BackgroundMusic.play_music(dialogue_data.bgm)
	
	#Iterate through the dialogue and get all mastered words with index and length
	if !dialogue_data.has("skip_dialogue"):
		var word : String = ""
		var tmp : String = dialogue_data.dialogue + " "
		var starting_tmp : int = 0
		for i in range(0, tmp.length()):
			if tmp[i] != " ":
				word += tmp[i]
			else:
				#Check if word is mastered
				var formatted_word = Global.format_word(word)
				var mastery = Global.get_word_mastery(formatted_word)
				print(formatted_word, mastery)
				if mastery.size() > 0:
					if mastery.accuracy >= Data.WORD_MASTERY_ACCURACY_BOUND and mastery.count >= Data.WORD_MASTERY_COUNT_BOUND:
						mastered_word_indices[starting_tmp] = word.length()
						mastered_words[formatted_word] = true
						skipped_characters_length += word.length()
				word = ""
				starting_tmp = i
	
	#Remove character
	if dialogue_data.has("remove_character"):
		for c in dialogue_data.remove_character:
			c.remove_character(!has_transition)
	if dialogue_data.has("remove_all_characters"):
		remove_characters(!has_transition)
	
	#Check dialogue options
	if dialogue_data.has("skip_dialogue"):
		skip_dialogue = true
		toggle_space_label(true)
	else:
		skip_dialogue = false
	if dialogue_data.has("location"):
		current_location = dialogue_data.location
		change_background(current_location)
	if dialogue_data.has("location_tint"):
		change_background("", dialogue_data.location_tint)
	
	#Show current character
	if dialogue_data.has("forced_name"):
		character_name.text = dialogue_data.forced_name
	else:
		character_name.text = dialogue_data.character
	
	if not character_dict.has(dialogue_data.character) and Data.characters.has(dialogue_data.character):
		add_character(dialogue_data.character, dialogue_data.outfit, dialogue_data.expression, dialogue_data.position)
	else:
		if dialogue_data.has("outfit"):
			modify_character(dialogue_data.character, dialogue_data.outfit)
		if dialogue_data.has("expression"):
			modify_character(dialogue_data.character, "", dialogue_data.expression)
		if dialogue_data.has("position"):
			modify_character(dialogue_data.character, "", "", dialogue_data.position)
		if dialogue_data.has("show_character"):
			for c in dialogue_data.show_character:
				toggle_character(c, false, has_transition)
		if dialogue_data.has("show_all_characters"):
			for c in character_dict:
				toggle_character(c, false, has_transition)
		if dialogue_data.has("hide_character"):
			for c in dialogue_data.hide_character:
				toggle_character(c, true, has_transition)
		if dialogue_data.has("hide_all_characters"):
			for c in character_dict:
				toggle_character(c, true, has_transition)
	
	#show other chracters
	if dialogue_data.has("show_more_characters"):
		for c in dialogue_data.show_more_characters:
			if not character_dict.has(c.character) and Data.characters.has(c.character):
				add_character(c.character, c.outfit, c.expression, c.position)
			else:
				modify_character(c.character, c.outfit, c.expression, c.position)
				
	
	#add character animation
	if dialogue_data.has("character_animation"):
		for c in dialogue_data.character_animation:
			if character_dict.has(c.character):
				character_dict[c.character].play_animation(c.anim)
	
	#Check if words should be skipped
	var has_mastered_words = false
	while mastered_word_indices.has(current_letter_index):
		current_letter_index += mastered_word_indices[current_letter_index] + int(current_letter_index != 0)
		has_mastered_words = true
	if has_mastered_words:
		current_letter_index += 1
	
	#dialogue remark
	if dialogue_data.has("dialogue_remark"):
		current_dialogue_remark = dialogue_data.dialogue_remark
	else:
		current_dialogue_remark = ""
	
	#Show current dialogue
	current_dialogue = dialogue_data.dialogue
	show_colored_dialogue(dialogue)
	
	#Add scene animation
	if dialogue_data.has("scene_animation"):
		apply_scene_animation(dialogue_data.scene_animation)
	
#Gets the next dialouge and calls get_current_dialogue
func set_next_dialogue() -> void:
	current_scene_index += 1
	mastered_word_indices.clear()
	mastered_words.clear()
	if(current_scene_index >= Data.dialogues[current_scene].size() - 1):
		var dialogue_data = Data.dialogues[current_scene][current_scene_index]
		print(dialogue_data)
		if dialogue_data.has("bad_end"):
			Global.play_sfx("BadEnd")
			BackgroundMusic.stop_music()
			bad_end_menu.show()
		else:
			show_stats_menu()
		Global.add_finished_scenes(current_scene)
		return
	get_current_dialogue()
	update_typebox("reset")
	
	if is_post_test and !user_time_informed:
		var cur_date : String = Time.get_date_string_from_system()
		var total_day_and_time : Dictionary = Global.get_total_day_and_session_time(cur_date)
		print(total_day_and_time.time + post_test_session_time, "??", total_day_and_time.day)
		if (total_day_and_time.time + post_test_session_time) >= Data.TOTAL_COLLECTION_TIME and (total_day_and_time.cur_day == 6 or total_day_and_time.cur_day == 7):
			Global.create_popup("10 mins requirement is done. You can already submit the data or continue playing", self)
			#time_menu.dialog_text = "10 mins requirement is done. You can already submit the data or continue playing."
			#time_menu.popup()
			user_time_informed = true
			is_post_test = false
			idle_timer.stop()
	
	if is_pre_test and pre_test_done:
		send_pretest_data()
		pre_test_done = false
		is_pre_test = false

#Shows current wpm, adds it to overall wpm, then resets info for new wpm
func register_wpm() -> void:
	if total_time > 0:
		print(current_dialogue.length(), "-", skipped_characters_length, "-", total_time)
		current_wpm = (current_dialogue.length() - skipped_characters_length) * 60 / (5 * total_time)
		total_wpm[0] += current_wpm
		total_wpm[1] += 1
		Global.add_overall_wpm(current_wpm)
		wpm_label.text = "WPM : " + String(floor(current_wpm))
	else:
		wpm_label.text = "WPM : -"
	tracing_wpm = false
	total_time = 0
	skipped_characters_length = 0

func toggle_space_label(b : bool) -> void:
	if b:
		space_label.show()
	else:
		space_label.hide()

#adds history text
func add_history_text(type : String, name : String, dialogue : String, remark : String = "") -> void:
	var text : String = ""
	if type == "dialogue":
		text = "[color=#" + light_blue.to_html(false) + "]" + name + ":  [/color]" + dialogue
	else:
		text = "[color=#" + yellow.to_html(false) + "]" + dialogue + "[/color]"
	if remark != "":
		text += " [color=#" +  light_orange.to_html(false) + "]" + remark + "[/color]"
	history_text_storage += text + "\n"
	history_text.parse_bbcode(history_text_storage)

#Sets neccesary variables to be ready for the next scene
func set_next_scene(scene_name : String, scene_index : int = 0, ready_dialogue : bool = true, retain_characters : bool = false) -> void:
	current_scene = scene_name
	current_scene_index = scene_index
	current_letter_index = 0
	wrong_letter_length = 0
	total_wpm = [0, 0]
	total_accuracy = [0, 0]
	total_time = 0
	typing_target = "dialogue"
	mastered_word_indices.clear()
	typed_word_accuracy.clear()
	mastered_words.clear()
	current_word_index = 0
	#Remove choice selections
	for selection in choice_selections:
		selection.queue_free()
	choice_selections = []
	ignore_typing = false
	has_choice_timer = false
	chosen_selection = null
	choosing_selection = false
	if !retain_characters:
		remove_characters(false)
		character_dict.clear()
	update_typebox("reset")
	if ready_dialogue:
		get_current_dialogue(true)

#Shows the dialogue on the display with color and alignment
func show_colored_dialogue(textbox : RichTextLabel, alignment : String = "") -> void:
	#Replace current_dialogue [name]
	current_dialogue = current_dialogue.replacen("[name]", Global.user_data["Name"])
	current_dialogue_remark = current_dialogue_remark.replacen("[name]", Global.user_data["Name"])
	
	if skip_dialogue:
		var remark = ""
		if current_dialogue_remark != "":
			remark = " [color=#" + light_blue.to_html(false) + "]" + current_dialogue_remark + "[/color]"
		textbox.parse_bbcode("[color=#" + light_orange.to_html(false) + "]" + current_dialogue + "[/color]" + remark)
		return
		
	var green_text = format_color_paragraph(mastered_words, current_dialogue.substr(0, current_letter_index), green)
	var red_text = ""
	if wrong_letter_length > 0:
		red_text = format_color_paragraph(mastered_words, current_dialogue.substr(current_letter_index, wrong_letter_length), red)
	var white_text = format_color_paragraph(mastered_words, current_dialogue.substr(current_letter_index + wrong_letter_length, current_dialogue.length()), white)
	
	var alignment_start_tag = ""
	var alignment_close_tag = ""
	if alignment != "":
		alignment_start_tag = "[" + alignment + "]"
		alignment_close_tag = "[/" + alignment + "]"
	
	var remark = ""
	if current_dialogue_remark != "":
		remark = " [color=#" + light_blue.to_html(false) + "]" + current_dialogue_remark + "[/color]"
	
	textbox.parse_bbcode(alignment_start_tag + "\"" + green_text + red_text + white_text + "\"" + alignment_close_tag + remark)

#Gets the words that should be ignored and adds a yellow color and striketrough
func format_color_paragraph(words : Dictionary, paragraph : String, color : Color) -> String:
	var color_start_tag = "[color=#" + color.to_html(false) + "]"
	var color_end_tag = "[/color]"
	var color_strikethrough = yellow
	paragraph = color_start_tag + paragraph
	
	if typing_target == "choice":
		return paragraph + color_end_tag
	
	for word in words:
		var index = paragraph.findn(word, 0)
		while index > -1 and index < paragraph.length():
			if index + word.length() < paragraph.length():
				if not Data.unnecessary_characters.has(paragraph[index + word.length()]):
					index += 1
					continue
			if index - 1 > 0:
				if not Data.unnecessary_characters.has(paragraph[index-1]):
					index += 1
					continue
			
			var orig_word = paragraph.substr(index, word.length())
			paragraph.erase(index, word.length())
			if color == green:
				color_strikethrough = green
			paragraph = paragraph.insert(index, color_end_tag + add_strikethrough_and_color(orig_word, color_strikethrough) + color_start_tag)
			index = paragraph.findn(word, index + word.length() + 2 + color_end_tag.length() + color_start_tag.length())
		#paragraph = paragraph.replacen(word, add_strikethrough(word))
	paragraph += color_end_tag
	return paragraph

func add_strikethrough_and_color(word : String, color : Color) -> String:
	return "[color=#" + color.to_html(false) + "][s]" + word + "[/s][/color]"

func _unhandled_input(event : InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if !pause_menu.visible and !stats_menu.visible and !bad_end_menu.visible and !history_menu.visible and !intro_menu.visible and !save_and_load_menu.visible and !tutorial_menu.visible and !timer_node.visible and !ignore_typing:
			Global.play_sfx("Cancel")
			get_tree().paused = true
			pause_menu.get_node("BGMSlide").value = Global.user_data["Music"]
			pause_menu.get_node("SFXSlide").value = Global.user_data["Sfx"]
			pause_menu.show()
	
	if ignore_typing or tutorial_menu.visible or name_menu.visible or intro_menu.visible:
		return
	
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		#Reset idle timer and continue testing timer
		if is_pre_test or is_post_test:
			idle_timer.stop()
			idle_timer.start(Data.IDLE_TIME)
			testing_timer.paused = false
		
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
		#Add sfx
		if !Data.ignored_keyboard_click_sfx_scancodes.has(typed_event.scancode):
			Global.play_keyboard_sfx()
		
		#start tracing wpm (RECHECK)
		if typed_event.unicode != 0:
			tracing_wpm = true
			
		if stats_menu.visible:
			if typed_event.scancode == 32:
				get_current_dialogue()
				update_typebox("reset")
				stats_menu.hide()
			return
		elif bad_end_menu.visible:
			if typed_event.scancode == 32:
				SceneTransition.add_transition("DiamondTilesCover")
				yield(SceneTransition, "transition_finished")
				get_current_dialogue()
				
				#Load last branch
				for c in saved_info_for_branching.characters:
					if !character_dict.has(c.name):
						add_character(c.name, c.outfit, c.expression, c.position)
					if c.is_hidden:
						toggle_character(c.name, true)
				#get_current_dialogue()
				#get_current_dialogue(false)
				current_location = saved_info_for_branching.location
				change_background(current_location, saved_info_for_branching.tint)
				BackgroundMusic.play_music(saved_info_for_branching.bgm)
				
				update_typebox("reset")
				bad_end_menu.hide()
				
			return
			
		#Focus on finding the choice selection if choosing selection is true
		if choosing_selection:
			var has_chosen_selection = false
			for selection in choice_selections:
				var selection_text = selection.choice_label_text
				if selection_text.substr(0, 1) == key_typed:
					chosen_selection = selection
					chosen_selection.set_background("active")
					current_dialogue = selection_text
					choosing_selection = false
					has_chosen_selection = true
			if not has_chosen_selection:
				return
		
		var character_to_type = current_dialogue.substr(current_letter_index, 1)
		
		if typed_event.scancode == 32:
			dialogue_space = true
		else:
			dialogue_space = false
		
		#Update Typebox
		if Input.is_action_pressed("ui_backspace"):
			update_typebox("delete")
			if wrong_letter_length <= 0:
				if not current_letter_index <= 0 and not current_dialogue[current_letter_index-1] == " ":
					current_letter_index -= 1
					if typing_target == "dialogue":
						show_colored_dialogue(dialogue)
					elif typing_target == "choice":
						show_colored_dialogue(chosen_selection.choice_text, "center")
			else:
				wrong_letter_length -= 1
		else:
			if typed_event.unicode != 0:
				if current_letter_index > current_dialogue.length():
					current_letter_index = current_dialogue.length()
					key_typed = character_to_type
					wrong_letter_length = 0
				else:
					update_typebox("add", key_typed)
			
		#TESTING
		if (skip_dialogue and typed_event.scancode == 32) or (debug_mode and typed_event.scancode == 16777233):
			current_letter_index = current_dialogue.length()
			key_typed = character_to_type
			wrong_letter_length = 0
			total_time = 0
			typed_event.scancode = 32
		
		if (debug_mode and typed_event.scancode == 16777232):
			current_letter_index = current_dialogue.length()
			key_typed = character_to_type
			wrong_letter_length = 0
			total_time = 0
			current_scene_index = Data.dialogues[current_scene].size()-2
			typed_event.scancode = 16777232
		
		#RECHECK THIS (SPACE AFTER DIALOGUE), TESTING?
		if current_letter_index == current_dialogue.length()-1 and (key_typed == character_to_type and wrong_letter_length <= 0):
			#key_typed = character_to_type
			#wrong_letter_length = 0
			register_wpm()
			toggle_space_label(true)
			if has_choice_timer:
				set_selection_timer("stop")
		elif current_letter_index >= current_dialogue.length():
			key_typed = character_to_type
			wrong_letter_length = 0
			toggle_space_label(false)
		
		#Update Dialogue
		if key_typed == character_to_type and wrong_letter_length <= 0:
			wrong_letter_length = 0
			
			#If mastered word is encountered, skip
			while mastered_word_indices.has(current_letter_index) and typing_target != "choice":
				current_letter_index += mastered_word_indices[current_letter_index] + 1
				if current_letter_index > current_dialogue.length():
					current_letter_index = current_dialogue.length()
				
			if not mastered_word_indices.has(current_letter_index) or typing_target == "choice":
				current_letter_index += 1
			
			if current_letter_index >= current_dialogue.length() and typed_event.scancode == 32:
				#Call show_colored_dialouge again to color the last letter
				if typing_target == "dialogue":
					show_colored_dialogue(dialogue)
					
				#Call word mastery to include last word and register WPM
				check_word_mastery("add")
				#register_wpm()
				update_typebox("reset")
				
				#wpm box reset
				wpm_label.text = "WPM : -"
				
				#If the dialogue has choices, switch typing target to choice
				current_letter_index = 0
				if Data.dialogues[current_scene][current_scene_index].has("show_selection") and typing_target == "dialogue":
					show_selection(Data.dialogues[current_scene][current_scene_index].show_selection)
					if Data.dialogues[current_scene][current_scene_index].has("show_selection_timer"):
						set_selection_timer("start", Data.dialogues[current_scene][current_scene_index].show_selection_timer)
					add_history_text(typing_target, character_name.text, current_dialogue, current_dialogue_remark)
					typing_target = "choice"
					update_typebox("reset")
				elif typing_target == "choice":
					if has_choice_timer:
						set_selection_timer("stop")
					add_history_text(typing_target, character_name.text, current_dialogue)
					#Global.add_finished_scenes(current_scene)
					
					#If same scene, do not reset, change index only and run ncessessary functions
					if chosen_selection.next_scene_name == current_scene:
						current_scene_index = chosen_selection.next_scene_index
						update_typebox("reset")
						typing_target = "dialogue"
						get_current_dialogue()
						#Remove choice selections
						for selection in choice_selections:
							selection.queue_free()
						choice_selections = []
						ignore_typing = false
						has_choice_timer = false
						chosen_selection = null
						choosing_selection = false
						
					else:
						set_next_scene(chosen_selection.next_scene_name, chosen_selection.next_scene_index) 
						
				elif typing_target == "dialogue":
					add_history_text(typing_target, character_name.text, current_dialogue, current_dialogue_remark)
					set_next_dialogue()
		else:
			#Space should also be included as wrong letter
			if typed_event.unicode != 0 or typed_event.scancode == 32:
				wrong_letter_length += 1
		
		if typing_target == "dialogue":
			show_colored_dialogue(dialogue)
		elif typing_target == "choice":
			if chosen_selection != null:
				current_dialogue_remark = ""
				show_colored_dialogue(chosen_selection.choice_text, "center")

func show_stats_menu():
	var title_label = stats_menu.get_node("TitleLabel")
	var cur_stats_label = stats_menu.get_node("CurrentStatsLabel")
	var overall_stats_label = stats_menu.get_node("OverallStatsLabel")
	var time_spent_label = stats_menu.get_node("TimeSpentLabel")
	var letter_diff_label = stats_menu.get_node("LetterDifficultyLabel")
	
	var cur_wpm = 0
	var cur_accuracy = 0
	if total_wpm[1] > 0:
		cur_wpm = total_wpm[0] / float(total_wpm[1])
	if total_accuracy[0] + total_accuracy[1] > 0:
		cur_accuracy = total_accuracy[0] / float(total_accuracy[0] + total_accuracy[1])
	var overall_stats = Global.get_user_stats()
	
	title_label.text = current_scene + " - DONE"
	cur_stats_label.text = "CURRENT WPM: " + String(round(cur_wpm)) + "\nCURRENT ACCURACY: " + String(round(cur_accuracy * 100))
	overall_stats_label.text = "OVERALL WPM: " + String(round(overall_stats["WPM"])) + "\nOVERALL ACCURACY: " + String(round(overall_stats["Accuracy"] * 100))
	time_spent_label.text = "TIME SPENT: " + String(stepify(chapter_play_time / 60, 0.01)) + " MINS"
	letter_diff_label.text = "KEYS THAT SHOULD BE PRACTICIED: "
	
	#Reset time spent/RECHECK/TESTING
	chapter_play_time = 0
	
	var diff_letters = overall_stats["Difficult_Letters"]
	print(diff_letters,"?")
	if diff_letters.size() <= 0:
		letter_diff_label.text += "NONE"
	else:
		for i in range(0, diff_letters.size() - 1):
			letter_diff_label.text += String(diff_letters[i])
			if i < diff_letters.size() - 2:
				letter_diff_label.text += ", "
	print(Global.user_data)
	
	Global.play_sfx("ChapterDone")
	BackgroundMusic.stop_music()
	stats_menu.show()

func show_intro_menu(starting_delay:float = 0):
	if !Data.chapter_details.has(current_scene):
		#Play bgm if there is one
		var dialogue_data = Data.dialogues[current_scene][current_scene_index]
		if dialogue_data.has("bgm"):
			BackgroundMusic.play_music(dialogue_data.bgm)
		return
	intro_menu.modulate.a = 1
	intro_menu.show()
	var tween = intro_menu.get_node("Tween")
	intro_label.text = Data.chapter_details[current_scene].Title + Data.chapter_details[current_scene].Subtitle
	intro_label.percent_visible = 0
	tween.interpolate_property(intro_label, "percent_visible", 0.0, 1.0, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	if starting_delay > 0:
		tween.playback_speed = 0
		yield(get_tree().create_timer(starting_delay), "timeout")
	tween.playback_speed = 1.0
	yield(tween,"tween_completed")
	yield(get_tree().create_timer(2.0), "timeout")
	tween.interpolate_property(intro_menu, "modulate:a", intro_menu.modulate.a, 0.0, 0.75, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,"tween_completed")
	intro_menu.hide()
	
	#Play bgm if there is one
	var dialogue_data = Data.dialogues[current_scene][current_scene_index]
	if dialogue_data.has("bgm"):
		BackgroundMusic.play_music(dialogue_data.bgm)

func show_save_and_load_menu(type : String) -> void:
	if timer_node.visible:
		return
		
	if type == "save":
		salm_title_label.text = "SAVE MENU"
		
	elif type == "load":
		salm_title_label.text = "LOAD MENU"
	
	for i in range(0, 8):
		if Global.user_data["SavedProgress"][i].size() <= 0:
			salm_slots[i].text = "EMPTY"
			salm_slots[i].get_node("Text").text = ""
		else:
			if Global.user_data["SavedProgress"][i].has("image_path"):
				salm_slots[i].icon = load(Global.user_data["SavedProgress"][i]["image_path"])
			salm_slots[i].text = ""
			salm_slots[i].get_node("Text").text = Global.user_data["SavedProgress"][i]["scene"] + ": " + Global.user_data["SavedProgress"][i]["save_date"]
	save_and_load_menu.show()
	Global.play_sfx("Cancel")

func navigate_tutorial_menu(next : bool = true) -> void:
	var cur_frame = tutorial_images.frame
	var max_frame = tutorial_images.frames.get_frame_count("default")
	
	if next:
		if cur_frame+1 < max_frame:
			cur_frame += 1
		else:
			#Finish
			tutorial_menu.hide()
			
		if cur_frame+1 == max_frame:
			tutorial_menu.get_node("TutorialNextBtn/Label").text = "FINISH"
				
		if cur_frame == 1:
			tutorial_menu.get_node("TutorialPrevBtn").show()
	else:
		if cur_frame > 0:
			cur_frame -= 1
		if cur_frame == 0:
			tutorial_menu.get_node("TutorialPrevBtn").hide()
		tutorial_menu.get_node("TutorialNextBtn/Label").text = "NEXT"
		
	tutorial_images.frame = cur_frame
	tutorial_title_label.text = "TUTORIAL (" + String(cur_frame + 1) + "/" + String(max_frame) + ")" 
	Global.play_sfx("Select")

func register_stats() -> void:
	var wpm_res = 0
	var accuracy_res = 0
	if total_wpm[1] > 0:
		wpm_res = (total_wpm[0] / float(total_wpm[1]))
	if total_accuracy[0] + total_accuracy[1] > 0:
		accuracy_res = (total_accuracy[0] / float(total_accuracy[0] + total_accuracy[1]))
	#Save this locally
	Global.save_research_variables("StoryMode", current_date, wpm_res, accuracy_res, current_session_time)

func send_pretest_data():
	var wpm_res = (total_wpm[0] / float(total_wpm[1]))
	var accuracy_res = (total_accuracy[0] / float(total_accuracy[0] + total_accuracy[1]))
	#Save this locally
	Global.save_research_variables("StoryMode", current_date, wpm_res, accuracy_res, Data.TOTAL_COLLECTION_TIME)
	#Send to google forms
	Global.send_data("PRE_TEST", Global.user_data.SchoolID, current_date, wpm_res, accuracy_res)
	
	#var http = HTTPClient.new()
	#var data = {
	#	"entry.1677198908" : Global.user_data.Name, 
	#	"entry.1636518983" : current_date,
	#	"entry.783576330" : wpm_res,
	#	"entry.2103345753" : accuracy_res, 
	#}
	#var pool_headers = PoolStringArray(Data.HTTP_HEADERS)
	#data = http.query_string_from_dict(data)
	#var result = http_request.request(Data.PRE_TEST_URLFORM, pool_headers, false, HTTPClient.METHOD_POST, data)
	
	#Save data
	Global.save_user_data()
	Global.create_popup("10 mins requirement is done. Pre-test data has been automatically sent to us. You can still continue playing", self)
	idle_timer.stop()
	testing_timer.stop()
	
#==========Connected Functions==========#
func _on_save_or_load_progress(index):
	if salm_title_label.text == "SAVE MENU":
		if Global.user_data["SavedProgress"][index].has("save_date"):
			save_slot_index = index
			save_confirmation_popup.popup()
			return
		save_progress(index)
	else:
		if Global.user_data["SavedProgress"][index].size() > 0:
			load_saved_progress(index)
	Global.play_sfx("Confirm")
		#get_current_dialogue()

func _on_SaveButton_pressed():
	show_save_and_load_menu("save")

func _on_LoadButton_pressed():
	show_save_and_load_menu("load")

func _on_ChoiceTimer_timeout():
	#timer_pop_up.show()
	Global.create_popup("Time is up! You can practice typing by playing Challenges!", self, "_on_TimerPopUp_confirmed")
	BackgroundMusic.stop_music(false)
	Global.play_sfx("BadEnd")
	ignore_typing = true
	set_selection_timer("stop")
	
func _on_TimerPopUp_confirmed():
	ignore_typing = false
	choosing_selection = false
	typing_target = "dialogue"
	current_letter_index = 0
	wrong_letter_length = 0
	mastered_word_indices.clear()
	typed_word_accuracy.clear()
	mastered_words.clear()
	current_word_index = 0
	for selection in choice_selections:
		selection.queue_free()
	choice_selections = []
	chosen_selection = null
	update_typebox("reset")
	get_current_dialogue()
	BackgroundMusic.resume_music()

func on_scene_transition_finished():
	pass

func _on_HistoryButton_pressed():
	if timer_node.visible:
		return
	history_menu.show()
	get_tree().paused = true
	Global.play_sfx("Cancel")

func _on_HideHistoryButton_pressed():
	history_menu.hide()
	get_tree().paused = false
	Global.play_sfx("Confirm")

func _on_NameChangeButton_pressed():
	Global.change_name(name_edit.text)
	Global.play_sfx("Confirm")
	name_menu.hide()

func _on_TestButton2_pressed():
	if !is_pre_test:
		Global.user_data["SavedDataResearch"]["StoryMode"][current_date]["time"] += current_session_time
	Global.user_data["TotalTimeSpent"][0] += current_session_time
	Global.switch_scene("MainMenu")

func _on_HideSalmMenu_pressed():
	save_and_load_menu.hide()
	Global.play_sfx("Select")

func _on_SaveConfirmationPopUp_confirmed():
	save_progress(save_slot_index)

func _on_TutorialNextBtn_pressed():
	navigate_tutorial_menu()

func _on_TutorialPrevBtn_pressed():
	navigate_tutorial_menu(false)

func _on_TestingTimer_timeout():
	pre_test_done = true

func _on_IdleTimer_timeout():
	testing_timer.paused = true
	idle_timer.stop()
	print("User is idle")

func _on_PauseResumeBtn_pressed():
	pause_menu.hide()
	get_tree().paused = false
	Global.play_sfx("Select")

func _on_MainMenuBtn_pressed():
	get_tree().paused = false
	if !is_pre_test:
		#Global.user_data["SavedDataResearch"]["StoryMode"][current_date]["time"] += current_session_time
		register_stats()
	Global.user_data["TotalTimeSpent"][0] += current_session_time
	Global.save_user_data()
	Global.switch_scene("MainMenu")
	Global.play_sfx("Select")

func _on_SFXSlide_drag_ended(value_changed):
	Global.user_data["Sfx"] = pause_menu.get_node("SFXSlide").value
	Global.play_sfx("Confirm")

func _on_BGMSlide_value_changed(value):
	BackgroundMusic.volume_db = value
	Global.user_data["Music"] = value
