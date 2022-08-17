extends Node2D

#==========Variables==========#
const white : Color = Color("#FFFFFF")
const red : Color = Color("#FF0000")
const green : Color = Color("#90EE90")

var current_scene : String = "Scene 1"
var current_scene_index: int = 3
var current_letter_index : int = 0
var wrong_letter_length : int = 0
var current_dialogue : String = ""
var typing_target : String = "dialogue" #dialogue or choice
var choosing_selection : bool = false
var chosen_selection : Node2D
var	choice_selections : Array = []

#==========Onready Variables==========#
onready var ui : Node2D = $UI
onready var character_name : RichTextLabel = $UI/CharacterName
onready var dialogue : RichTextLabel = $UI/Dialogue
onready var type_box :RichTextLabel = $UI/TypeBox
onready var choice_selection_position = $UI/ChoiceSelectionPosition

onready var choice_selection = preload("res://src/ui/ChoiceSelection.tscn")

#==========Functions==========#
func _ready() -> void:
	get_current_dialogue()

#Incharge of displaying selections
func show_selection(selections) -> void:
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
func update_typebox(type, letter = '') -> void:
	if type == "delete":
		var s = type_box.text
		if s.length() > 0:
			s.erase(s.length() - 1, 1)
			type_box.text = s
	elif type == "add":
		if letter == " " and wrong_letter_length == 0:
			type_box.text = ""
		else:
			type_box.text += letter
	elif type == "reset":
		type_box.text = ""

#Gets and sets the current dialogue and and calls show_colored_dialogue()
func get_current_dialogue() -> void:
	#Show current character
	character_name.text = Data.dialogues[current_scene][current_scene_index].character
	
	#Show current dialogue
	current_dialogue = Data.dialogues[current_scene][current_scene_index].dialogue
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
func set_next_scene(scene_name) -> void:
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
		if key_typed == character_to_type:
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
			if typed_event.unicode != 0:
				wrong_letter_length += 1
				
		if typing_target == "dialogue":
			show_colored_dialogue(dialogue)
		elif typing_target == "choice":
			if chosen_selection != null:
				show_colored_dialogue(chosen_selection.choice_text)
