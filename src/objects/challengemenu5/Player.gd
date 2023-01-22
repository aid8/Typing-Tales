extends KinematicBody2D

#==========TODO==========#

#==========Variables==========#
export (Color) var blue : Color = Color("#ADD8E6")
export (Color) var green : Color = Color("#90EE90")
export (Color) var white : Color = Color("#FFFFFF")

var SPEED : float = 150
var OFFSET : Vector2 = Vector2(130, 60)

var motion : Vector2 = Vector2()
var direction_words = []
var text = ""
var text_label = null
var direction = "none"
var selected_direction = "none"
var directions = ["Up", "Down", "Right", "Left"]
var proceed_direction = false
var type = "player"

#==========Onready Variables==========#
onready var labels = [$UpLabel, $DownLabel, $RightLabel, $LeftLabel]

#==========Preload Variables==========#

#==========Functions==========#
func _ready():
	init()
	
func _physics_process(delta):
	if direction == "none" or !proceed_direction:
		return
	
	motion.x = 0
	motion.y = 0
	if direction == "Down":
		motion.y = SPEED * delta
	elif direction == "Up":
		motion.y = -SPEED * delta
	elif direction == "Right":
		motion.x = SPEED * delta
	elif direction == "Left":
		motion.x = -SPEED * delta
	
	translate(motion)
	screen_wrap()

func screen_wrap():
	var screen_size = get_viewport_rect().size
	position.x = wrapf(position.x, -OFFSET.x, screen_size.x + OFFSET.x)
	position.y = wrapf(position.y, -OFFSET.y, screen_size.y + OFFSET.y)

func init():
	for i in range(4):
		direction_words.append(WordList.get_prompt(get_starting_letters()))
		text_label = labels[i]
		text = direction_words[i]
		set_next_character(-1)
	text_label = null

func select_direction(word):
	for i in range(4):
		if labels[i].text == word:
			text_label = labels[i]
			text = direction_words[i]
			selected_direction = directions[i]
			break

func change_direction():
	direction = selected_direction
	proceed_direction = true

func reset_direction(word):
	for i in range(4):
		if labels[i].text == word:
			direction_words[i] = WordList.get_prompt(get_starting_letters())
			text_label = labels[i]
			text = direction_words[i]
			set_next_character(-1)
			text_label = null
			break

func get_starting_letters() -> Array:
	var texts = []
	for text in direction_words:
		if text.length() > 0:
			texts.append(text[0])
	return texts

func get_prompts() -> String:
	return direction_words

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
