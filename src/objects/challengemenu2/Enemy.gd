extends KinematicBody2D
#==========Variables==========#
var ACCELERATION = 100
var FRICTION = 200
var MAX_SPEED = 80 #30

export (Color) var blue : Color = Color("#76b6e9")
export (Color) var green : Color = Color("#90EE90")
export (Color) var white : Color = Color("#FFFFFF")

var knockback : Vector2 = Vector2.ZERO
var velocity : Vector2 = Vector2.ZERO
var enemy_vol : Vector2 = Vector2.ZERO
var enemy_old_pos
var target
var text : String = ""
var type : String = "Enemy"

var shake_strength : float = 0
var shake_decay : float = 0
var cur_text_position : Vector2

#==========Onready Variables==========#
onready var rand = RandomNumberGenerator.new()
onready var text_label : RichTextLabel = $TextLabel
onready var anim : AnimatedSprite = $Anim

#==========Functions==========#
func _ready():
	enemy_old_pos = global_position
	text = WordList.get_prompt(Global.current_menu.get_enemy_starting_letters())
	set_next_character(-1)
	randomize_animation()

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta : float) -> void:
	target = Global.current_menu.base

	velocity = velocity.move_toward((target.global_position - global_position).normalized() * MAX_SPEED, ACCELERATION * delta)
	velocity = move_and_slide(velocity)
	
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	#AI tower prediction
	enemy_vol = global_position - enemy_old_pos
	enemy_old_pos = global_position

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
	
func get_prompt() -> String:
	return text

func knockback_enemy(knockback_power : float = -1.5, knockback_pos : Vector2 = velocity) -> void:
	knockback = knockback_pos * knockback_power

func damage() -> void:
	self.queue_free()

func randomize_animation() -> void:
	var animations = anim.frames.get_animation_names()
	anim.animation = animations[randi() % animations.size()]

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
