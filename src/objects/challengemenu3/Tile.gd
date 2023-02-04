extends Node2D

#==========Variables==========#
export (Color) var blue : Color = Color("#ADD8E6")
export (Color) var green : Color = Color("#90EE90")
export (Color) var white : Color = Color("#FFFFFF")

export (Color) var tile_red : Color = Color("#FF0000")
export (Color) var tile_blue : Color = Color("#ADD8E6")
export (Color) var tile_green : Color =  Color("#90EE90")
export (Color) var tile_gray : Color
export (Color) var tile_start_highlight : Color
export (Color) var tile_end_highlight : Color
export (Color) var tile_canceled : Color = Color("#585858")

var text : String = ""
var current_color : Color

var shake_strength : float = 0
var shake_decay : float = 0
var cur_text_position : Vector2

#==========Onready Variables==========#
onready var rand = RandomNumberGenerator.new()
onready var color_rect = $ColorRect
onready var tile_text = $TextContainer/TileText
onready var highlight = $Highlight
onready var refresh_time_timer = $RefreshTileTimer
onready var anim = $Anim

#==========Functions==========#
func _ready():
	randomize()
	refresh_tile()

func _process(delta):
	handle_text_shake_anim(delta)
	
func handle_text_shake_anim(delta):
	#shake anim
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0, shake_decay * delta)
		var rand_off = rand.randf_range(-shake_strength, shake_strength)
		tile_text.rect_position = cur_text_position + Vector2(rand_off, 0)
		if floor(shake_strength) == 0:
			tile_text.rect_position = cur_text_position
			shake_strength = 0

func apply_text_shake(ss : float, sd : float) -> void:
	if shake_strength > 0:
		return
	shake_strength = ss
	shake_decay = sd
	cur_text_position = tile_text.rect_position

func delayed_refresh_tile(time : int):
	text = ""
	set_next_character(-1)
	color_rect.color = tile_gray
	anim.self_modulate = tile_canceled
	refresh_time_timer.wait_time = time
	refresh_time_timer.start()

func refresh_tile():
	text = WordList.get_prompt(Global.current_menu.get_tiles_starting_letters())
	set_next_character(-1)
	set_random_color()
	anim.self_modulate = white

func toggle_highlight(b : bool, type : String = "none") -> void:
	if type != "none":
		if type == "start":
			highlight.color = tile_start_highlight
			#anim.self_modulate = tile_start_highlight
		elif type == "end":
			highlight.color = tile_end_highlight
			#anim.self_modulate = tile_end_highlight
	if b:
		highlight.show()
	else:
		highlight.hide()

func cancel_tile():
	set_next_character(-1)
	toggle_highlight(false)

func get_current_color():
	return current_color

func get_prompt():
	return text

func set_random_color():
	var colors = [tile_blue, tile_green, tile_red]
	anim.frame = randi() % anim.frames.get_frame_count("default")
	current_color = colors[anim.frame]

func set_next_character(next_character_index: int) -> void:
	if next_character_index == -1:
		tile_text.parse_bbcode(set_center_tags(text))
		return
		
	var green_text = get_bbcode_color_tag(green) + text.substr(0, next_character_index) + get_bbcode_end_color_tag()
	var blue_text = get_bbcode_color_tag(blue) + text.substr(next_character_index, 1) + get_bbcode_end_color_tag()
	var white_text = ""
	if next_character_index != text.length():
		white_text = get_bbcode_color_tag(white) + text.substr(next_character_index + 1, text.length() - next_character_index + 1) + get_bbcode_end_color_tag()
	tile_text.parse_bbcode(set_center_tags(green_text + blue_text + white_text))

func set_center_tags(string_to_center: String) -> String:
	return "[center]" + string_to_center + "[/center]"
	
func get_bbcode_color_tag(color: Color) -> String:
	return "[color=#" + color.to_html(false) + "]"

func get_bbcode_end_color_tag() -> String:
	return "[/color]"

func _on_Timer_timeout():
	refresh_tile()
