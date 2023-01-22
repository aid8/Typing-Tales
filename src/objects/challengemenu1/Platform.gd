extends Area2D

#==========Variables==========#
const type = "Platform"

export (Color) var blue : Color = Color("#ADD8E6")
export (Color) var green : Color = Color("#90EE90")
export (Color) var white : Color = Color("#FFFFFF")

var text : String = ""
var available : bool = true

#==========Onready Variables==========#
onready var text_label : RichTextLabel = $TextLabel

#==========Functions==========#
func _ready():
	pass

func set_random_word() -> void:
	var platform_words = Global.current_menu.get_platform_words()
	var forbidden_letters = []
	for word in platform_words:
		if word == text:
			continue
		forbidden_letters.append(word[0])
	print(platform_words, "=", forbidden_letters)
	text = WordList.get_prompt(forbidden_letters)
	set_next_character(-1)

func toggle_text(hidden : bool) -> void:
	if hidden:
		text_label.hide()
		available = false
	else:
		text_label.show()
		available = true

func set_next_character(next_character_index: int) -> void:
	if next_character_index == -1:
		text_label.parse_bbcode(set_center_tags(text))
		return
		
	var green_text = get_bbcode_color_tag(green) + text.substr(0, next_character_index) + get_bbcode_end_color_tag()
	var blue_text = get_bbcode_color_tag(blue) + text.substr(next_character_index, 1) + get_bbcode_end_color_tag()
	var white_text = ""
	if next_character_index != text.length():
		white_text = get_bbcode_color_tag(white) + text.substr(next_character_index + 1, text.length() - next_character_index + 1) + get_bbcode_end_color_tag()
	text_label.parse_bbcode(set_center_tags(green_text + blue_text + white_text))

func set_center_tags(string_to_center: String) -> String:
	return "[center]" + string_to_center + "[/center]"
	
func get_bbcode_color_tag(color: Color) -> String:
	return "[color=#" + color.to_html(false) + "]"

func get_bbcode_end_color_tag() -> String:
	return "[/color]"

#==========Connected Functions==========#
func _on_Platform_body_entered(body):
	if body.type == "FallingObject":
		body.queue_free()
		Global.current_menu.subtract_lives()
