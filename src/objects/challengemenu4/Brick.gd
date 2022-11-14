extends KinematicBody2D

#==========Variables==========#
export (Color) var blue : Color = Color("#ADD8E6")
export (Color) var green : Color = Color("#90EE90")
export (Color) var white : Color = Color("#FFFFFF")
export (Color) var disabled_color : Color

var SPEED : float = 100
var type : String = "Brick"
var text : String = ""
var motion : Vector2 = Vector2()
var falling : bool = true

#==========Onready Variables==========#
onready var text_label = $TextLabel
#==========Preload Variables==========#

#==========Functions==========#
func _ready():
	text = WordList.get_prompt()
	set_next_character(-1)

func _physics_process(delta):
	if falling:
		motion.y = SPEED * delta
		translate(motion)

func get_prompt() -> String:
	return text

func disable_brick() -> void:
	falling = false
	text_label.parse_bbcode(set_center_tags(get_bbcode_color_tag(disabled_color) + text + get_bbcode_end_color_tag()))

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

func die():
	queue_free()
#==========Connected Functions==========#
func _on_BrickArea_body_entered(body):
	if body.get("type") == "Brick" and body != self:
		disable_brick()
		Global.current_menu.reset_brick()
