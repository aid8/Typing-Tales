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
#var new_progress : bool = true#if false, this will load the saved progress instead of a new one

#==========Onready Variables==========#
onready var ui : CanvasLayer = $UI
onready var characters : Node2D = $Characters
onready var backgrounds : AnimatedSprite = $Backgrounds
onready var character_name : RichTextLabel = $UI/CharacterName
onready var dialogue : RichTextLabel = $UI/Dialogue
onready var type_box :RichTextLabel = $UI/TypeBox
onready var choice_selection_position : Position2D = $UI/ChoiceSelectionPosition
onready var character_positions : Dictionary = {
	"LEFT" : $Characters/CharacterLeftPosition,
	"MIDDLE" : $Characters/CharacterMidPosition,
	"RIGHT" : $Characters/CharacterRightPosition,
}

#==========Preload Variables==========#
onready var choice_selection = preload("res://src/ui/ChoiceSelection.tscn")
onready var character = preload("res://src/objects/Character.tscn")

#==========Functions==========#
func _ready() -> void:
	#STILL TESTING HERE
	if not Global.check_first_time():
		ui.hide()
		testbox.connect("modal_closed", self, "cancelled")
		testbox.get_close_button().connect("pressed", self, "cancelled")
		testbox.get_cancel().connect("pressed", self, "cancelled")
		testbox.popup()
		return
	get_current_dialogue()

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

#Incharge of editing, updating TypeBox
#Also adds word mastery (for now it adds the word inside the dict) update this
func update_typebox(type : String, letter : String = '') -> void:
	if type == "delete":
		var s = type_box.text
		if s.length() > 0:
			s.erase(s.length() - 1, 1)
			type_box.text = s
	elif type == "add":
		if letter == " " and wrong_letter_length == 0 and current_dialogue[current_letter_index] == " ":
			Global.add_word_mastery(type_box.text)
			type_box.text = ""
		else:
			type_box.text += letter
	elif type == "reset":
		type_box.text = ""

#Gets and sets the current dialogue and and calls show_colored_dialogue()
func get_current_dialogue() -> void:
	var dialogue_data = Data.dialogues[current_scene][current_scene_index]
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
	
	#Show current dialogue
	current_dialogue = dialogue_data.dialogue
	show_colored_dialogue(dialogue)
	
#Gets the next dialouge and calls get_current_dialogue
func set_next_dialogue() -> void:
	current_scene_index += 1
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
	#Remove choice selections
	for selection in choice_selections:
		selection.queue_free()
	choice_selections = []
	update_typebox("reset")
	get_current_dialogue()

#Shows the dialogue on the display with color
func show_colored_dialogue(textbox : RichTextLabel) -> void:
	var green_text = "[color=#" + green.to_html(false) + "]" + current_dialogue.substr(0, current_letter_index) + "[/color]"
	var red_text
	if wrong_letter_length > 0:
		red_text = "[color=#" + red.to_html(false) + "]" + current_dialogue.substr(current_letter_index, wrong_letter_length) + "[/color]"
	else:
		red_text = ""
	var white_text = "[color=#" + white.to_html(false) + "]" + current_dialogue.substr(current_letter_index + wrong_letter_length, current_dialogue.length()) + "[/color]"
	textbox.parse_bbcode(green_text + red_text + white_text)

func _unhandled_input(event : InputEvent) -> void:
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
			update_typebox("add", key_typed)
		
		#Update Dialogue
		if key_typed == character_to_type and wrong_letter_length <= 0:
			wrong_letter_length = 0
			current_letter_index += 1
			if current_letter_index == current_dialogue.length():
				#Call show_colored_dialouge again to color the last letter
				if typing_target == "dialogue":
					show_colored_dialogue(dialogue)
					
				#If the dialogue has choices, switch typing target to choice
				current_letter_index = 0
				if Data.dialogues[current_scene][current_scene_index].has("show_selection") and typing_target == "dialogue":
					show_selection(Data.dialogues[current_scene][current_scene_index].show_selection)
					typing_target = "choice"
					update_typebox("reset")
				elif typing_target == "choice":
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
	get_tree().reload_current_scene()

func _on_ClearButton_pressed():
	#Delete data and Reload current scene
	Global.delete_user_data()
	get_tree().reload_current_scene()
