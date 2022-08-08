extends Node2D

#==========Variables==========#
const white : Color = Color("#FFFFFF")
const green : Color = Color("#90EE90")

var current_scene : String = "Scene 1"
var current_scene_index: int = 0
var current_letter_index : int = 0
var current_dialogue : String = ""

#==========Onready Variables==========#
onready var character_name : RichTextLabel = $CharacterName
onready var dialogue : RichTextLabel = $Dialogue

#==========Functions==========#
func _ready() -> void:
	get_current_dialogue()

func get_current_dialogue() -> void:
	#Show current character
	character_name.text = Data.dialogues[current_scene][current_scene_index].character
	
	#Show current dialogue
	current_dialogue = Data.dialogues[current_scene][current_scene_index].dialogue
	get_colored_dialogue()

func set_next_dialogue() -> void:
	current_scene_index += 1
	if(current_scene_index >= Data.dialogues[current_scene].size()):
		print("Scene is finished")
		return
	get_current_dialogue()

func get_colored_dialogue() -> void:
	var green_text = "[color=#" + green.to_html(false) + "]" + current_dialogue.substr(0, current_letter_index) + "[/color]"
	var white_text = "[color=#" + white.to_html(false) + "]" + current_dialogue.substr(current_letter_index, current_dialogue.length()) + "[/color]"
	dialogue.parse_bbcode(green_text + white_text)

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
		var character_to_type = current_dialogue.substr(current_letter_index, 1)
		print("Typed ", key_typed, " instead of ", character_to_type)
		if key_typed == character_to_type:
			current_letter_index += 1
			get_colored_dialogue()
			if current_letter_index == current_dialogue.length():
				current_letter_index = 0
				set_next_dialogue()
