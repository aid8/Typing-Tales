extends KinematicBody2D

#==========TODO==========#

#==========Variables==========#
const DIRECTION_ANGLES = {
	"Up" : -90,
	"Down" : 90,
	"Left" : 180,
	"Right" : 0,
}

export (Color) var blue : Color = Color("#76b6e9")
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

var shake_strength : float = 0
var shake_decay : float = 0
var cur_text_position : Vector2

#==========Onready Variables==========#
onready var rand = RandomNumberGenerator.new()
onready var labels : Array = [$UpLabel, $DownLabel, $RightLabel, $LeftLabel]
onready var anim : AnimatedSprite = $Anim

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

func _process(delta):
	handle_text_shake_anim(delta)
	
func handle_text_shake_anim(delta):
	#shake anim
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0, shake_decay * delta)
		var rand_off = rand.randf_range(-shake_strength, shake_strength)
		text_label.rect_position = cur_text_position + Vector2(rand_off, 0)
		if floor(shake_strength) == 0:
			text_label.rect_position = cur_text_position
			shake_strength = 0

func apply_text_shake(ss : float, sd : float) -> void:
	if shake_strength > 0:
		return
	shake_strength = ss
	shake_decay = sd
	cur_text_position = text_label.rect_position
	
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

func change_direction() -> void:
	hide_label(selected_direction)
	direction = selected_direction
	anim.rotation_degrees = DIRECTION_ANGLES[direction]
	proceed_direction = true

func hide_label(direction : String) -> void:
	var dir_index = {"Up" : 0, "Down" : 1, "Right" : 2, "Left" : 3}
	for i in range(0, 4):
		labels[i].show()
	labels[dir_index[direction]].hide()

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
