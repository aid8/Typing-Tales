extends Node2D

#==========Testing Stuffs==========#
onready var testbox = $TestBox

func _on_TestBox_confirmed():
	Global.load_user_data()
	load_saved_progress()
	get_current_dialogue()
	ui.show()

func cancelled():
	get_current_dialogue()
	ui.show()

#==========Variables==========#
const white : Color = Color("#FFFFFF")
const red : Color = Color("#FF0000")
const green : Color = Color("#90EE90")
const yellow : Color = Color("#8B8000")

var current_scene : String = "Scene 1"
var current_scene_index: int = 0
var current_letter_index : int = 0
var current_location : String = ""
var wrong_letter_length : int = 0
var current_dialogue : String = ""
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
#var new_progress : bool = true#if false, this will load the saved progress instead of a new one

#==========Onready Variables==========#
onready var ui : CanvasLayer = $UI
onready var characters : Node2D = $Characters
onready var backgrounds : AnimatedSprite = $Backgrounds
onready var character_name : RichTextLabel = $UI/CharacterName
onready var dialogue : RichTextLabel = $UI/Dialogue
onready var type_box :RichTextLabel = $UI/TypeBox
onready var type_box_background : ColorRect = $UI/TypeBoxBackground
onready var choice_selection_position : Position2D = $UI/ChoiceSelectionPosition
onready var character_positions : Dictionary = {
	"LEFT" : $Characters/CharacterLeftPosition,
	"MIDDLE" : $Characters/CharacterMidPosition,
	"RIGHT" : $Characters/CharacterRightPosition,
}
onready var choice_timer : Timer = $ChoiceTimer
onready var timer_pop_up : AcceptDialog = $UI/TimerPopUp
onready var timer_label : Label = $UI/TimerLabel

#==========Preload Variables==========#
onready var choice_selection = preload("res://src/ui/ChoiceSelection.tscn")
onready var character = preload("res://src/objects/Character.tscn")

#==========Functions==========#
func _ready() -> void:
	#TESTING
	if not Global.check_first_time():
		ui.hide()
		testbox.connect("modal_closed", self, "cancelled")
		testbox.get_close_button().connect("pressed", self, "cancelled")
		testbox.get_cancel().connect("pressed", self, "cancelled")
		testbox.popup()
		return
	get_current_dialogue()

func _process(delta) -> void:
	if has_choice_timer:
		timer_label.text = String(choice_timer.time_left)

#Loads necessary characters, location and scene
func load_saved_progress():
	var data = Global.user_data["SavedProgress"]
	current_scene = data.scene
	current_scene_index = data.scene_index
	for c in data.characters:
		add_character(c.name, c.outfit, c.expression, c.position)
		if c.is_hidden:
			toggle_character(c.name, true)
	current_location = data.location
	change_background(current_location)

#Creates a character array and puts all info about the characters present
#Then also saves scene info
func save_progress():
	var char_array : Array = []
	for c in character_dict.values():
		var char_info : Dictionary = {}
		char_info["name"] = c.character_name
		char_info["outfit"] = c.current_outfit
		char_info["expression"] = c.current_expression
		char_info["position"] = c.current_position
		char_info["is_hidden"] = c.is_hidden
		char_array.append(char_info)
	Global.add_user_data_story_progress(current_scene, current_scene_index, char_array, current_location)
	Global.save_user_data()
	print("Progress is saved!")

#Adds a character sprite on the screen
func add_character(name : String, outfit : String, expression : String, char_position: String):
	var c = character.instance()
	c.initialize(name, outfit, expression, char_position)
	c.position = character_positions[char_position].position
	characters.add_child(c)
	character_dict[name] = c
	
#Deletes the character instance with provided name
func remove_character(name : String):
	character_dict[name].queue_free()
	character_dict.erase(name)

#Deletes all character
func remove_characters():
	for c in character_dict.values():
		c.queue_free()
	character_dict = {}

#Shows/Hides the character depending on passed boolean (hidden)
func toggle_character(name : String, hidden : bool):
	character_dict[name].toggle_character(hidden)

#Changes the outfit/expression of the character, if parameter is blank, it will be ignored
func modify_character(name : String, outfit : String = "", expression : String = "", char_position : String = ""):
	if outfit != "":
		character_dict[name].change_outfit(outfit)
	if expression != "":
		character_dict[name].change_expression(expression)
	if char_position != "":
		character_dict[name].position = character_positions[char_position].position

#in charge of changing backgrounds
func change_background(location):
	backgrounds.animation = Data.backgrounds[location].Animation
	backgrounds.frame = Data.backgrounds[location].Frame

#Incharge of displaying selections
func show_selection(selections : Array) -> void:
	choosing_selection = true
	for i in range (0, selections.size()):
		var cs = choice_selection.instance()
		cs.next_scene_name = selections[i][1]
		cs.position = choice_selection_position.position
		cs.position.y += (100 * i)
		choice_selections.append(cs)
		ui.add_child(cs)
		cs.set_choice_text(selections[i][0])

#Incharge of selection ttimer
func set_selection_timer(type : String, time : float = 0) -> void:
	if type == "start":
		choice_timer.start(time)
		timer_label.show()
		has_choice_timer = true
	elif type == "stop":
		choice_timer.stop()
		timer_label.hide()
		has_choice_timer = false

#Incharge of editing, updating TypeBox
#Also adds word mastery
func update_typebox(type : String, letter : String = '') -> void:
	if type == "delete":
		var s = type_box.text
		if s.length() > 0:
			s.erase(s.length() - 1, 1)
			type_box.text = s
			current_word_index -= 1
			check_word_mastery("force_wrong")
	elif type == "add":
		if letter == " " and wrong_letter_length == 0 and current_dialogue[current_letter_index] == " ":
			check_word_mastery("add")
			type_box.text = ""
			check_word_mastery("reset")
		else:
			type_box.text += letter
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
		Global.add_word_mastery(type_box.text, word_accuracy)
		#Add letter mastery
		for i in range(type_box.text.length()):
			Global.add_letter_mastery(type_box.text[i], typed_word_accuracy[i])
		
	elif type == "reset":
		current_word_index = 0
		typed_word_accuracy = {}

#Gets and sets the current dialogue and and calls show_colored_dialogue()
func get_current_dialogue() -> void:
	var dialogue_data = Data.dialogues[current_scene][current_scene_index]
	
	#Iterate through the dialogue and get all mastered words with index and length
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
			if mastery.size() > 0:
				if mastery.accuracy >= Data.word_mastery_accuracy_bound and mastery.count >= Data.word_mastery_count_bound:
					mastered_word_indices[starting_tmp] = word.length()
					mastered_words[formatted_word] = true
			word = ""
			starting_tmp = i
			
	#Show background
	if dialogue_data.has("location"):
		current_location = dialogue_data.location
		change_background(current_location)
	
	#Show current character
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
			toggle_character(dialogue_data.show_character, false)
		if dialogue_data.has("hide_character"):
			toggle_character(dialogue_data.show_character, true)
		if dialogue_data.has("show_characters"):
			for c in character_dict:
				toggle_character(c, false)
		if dialogue_data.has("hide_characters"):
			for c in character_dict:
				toggle_character(c, true)
	
	#Check if words should be skipped
	var has_mastered_words = false
	while mastered_word_indices.has(current_letter_index):
		current_letter_index += mastered_word_indices[current_letter_index] + int(current_letter_index != 0)
		has_mastered_words = true
	if has_mastered_words:
		current_letter_index += 1
	
	#Show current dialogue
	current_dialogue = dialogue_data.dialogue
	show_colored_dialogue(dialogue)
	
#Gets the next dialouge and calls get_current_dialogue
func set_next_dialogue() -> void:
	current_scene_index += 1
	mastered_word_indices.clear()
	mastered_words.clear()
	if(current_scene_index >= Data.dialogues[current_scene].size()):
		print("Scene is finished")
		return
	get_current_dialogue()
	update_typebox("reset")

#Sets neccesary variables to be ready for the next scene
func set_next_scene(scene_name : String) -> void:
	current_scene = scene_name
	current_scene_index = 0
	current_letter_index = 0
	wrong_letter_length = 0
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
	update_typebox("reset")
	get_current_dialogue()

#Shows the dialogue on the display with color
func show_colored_dialogue(textbox : RichTextLabel) -> void:
	var green_text = "[color=#" + green.to_html(false) + "]" + add_paragraph_strikethrough(mastered_words, current_dialogue.substr(0, current_letter_index)) + "[/color]"
	var red_text = ""
	if wrong_letter_length > 0:
		red_text = "[color=#" + red.to_html(false) + "]" + add_paragraph_strikethrough(mastered_words, current_dialogue.substr(current_letter_index, wrong_letter_length)) + "[/color]"
	var white_text = "[color=#" + white.to_html(false) + "]" + add_paragraph_strikethrough(mastered_words, current_dialogue.substr(current_letter_index + wrong_letter_length, current_dialogue.length())) + "[/color]"
	textbox.parse_bbcode(green_text + red_text + white_text)

func add_paragraph_strikethrough(words : Dictionary, paragraph : String) -> String:
	if typing_target == "choice":
		return paragraph
	for word in words:
		var index = paragraph.findn(word, 0)
		#REVIEW THIS, did not use replacen since capitalization is removed
		while index > -1:
			var orig_word = paragraph.substr(index, word.length())
			paragraph.erase(index, word.length())
			paragraph = paragraph.insert(index, add_strikethrough(orig_word))
			index = paragraph.findn(word, index+word.length()+2)
		#paragraph = paragraph.replacen(word, add_strikethrough(word))
	return paragraph

func add_strikethrough(word : String) -> String:
	return "[s]" + word + "[/s]"

func _unhandled_input(event : InputEvent) -> void:
	if ignore_typing:
		return
	
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
		#Focus on finding the choice selection if choosing selection is true
		if choosing_selection:
			var has_chosen_selection = false
			for selection in choice_selections:
				var selection_text = selection.choice_text.text
				if selection_text.substr(0, 1) == key_typed:
					chosen_selection = selection
					current_dialogue = selection_text
					choosing_selection = false
					has_chosen_selection = true
			if not has_chosen_selection:
				return
		
		var character_to_type = current_dialogue.substr(current_letter_index, 1)
		#Update Typebox
		if Input.is_action_pressed("ui_backspace"):
			update_typebox("delete")
			if wrong_letter_length <= 0:
				if not current_letter_index <= 0 and not current_dialogue[current_letter_index-1] == " ":
					current_letter_index -= 1
					if typing_target == "dialogue":
						show_colored_dialogue(dialogue)
					elif typing_target == "choice":
						show_colored_dialogue(chosen_selection.choice_text)
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
			
			if current_letter_index >= current_dialogue.length():
				#Call show_colored_dialouge again to color the last letter
				if typing_target == "dialogue":
					show_colored_dialogue(dialogue)
					
				#Call word mastery to include last word
				check_word_mastery("add")
				
				#If the dialogue has choices, switch typing target to choice
				current_letter_index = 0
				if Data.dialogues[current_scene][current_scene_index].has("show_selection") and typing_target == "dialogue":
					show_selection(Data.dialogues[current_scene][current_scene_index].show_selection)
					if Data.dialogues[current_scene][current_scene_index].has("show_selection_timer"):
						set_selection_timer("start", Data.dialogues[current_scene][current_scene_index].show_selection_timer)
					typing_target = "choice"
					update_typebox("reset")
				elif typing_target == "choice":
					if has_choice_timer:
						set_selection_timer("stop")
					set_next_scene(chosen_selection.next_scene_name)
				elif typing_target == "dialogue":
					set_next_dialogue()
		else:
			#Space should also be included as wrong letter
			if typed_event.unicode != 0 or typed_event.scancode == 32:
				wrong_letter_length += 1
		
		if typing_target == "dialogue":
			show_colored_dialogue(dialogue)
		elif typing_target == "choice":
			if chosen_selection != null:
				show_colored_dialogue(chosen_selection.choice_text)

#==========Connected Functions==========#
func _on_SaveButton_pressed():
	save_progress()

func _on_LoadButton_pressed():
	#Just restart scene for now
	#TESTING
	get_tree().reload_current_scene()

func _on_ClearButton_pressed():
	#Delete data and Reload current scene
	Global.delete_user_data()
	get_tree().reload_current_scene()

func _on_ChoiceTimer_timeout():
	timer_pop_up.show()
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
