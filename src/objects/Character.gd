extends Node2D

#==========Variables==========#
var character_name : String
var current_outfit : String
var current_expression : String
var current_position : String
var is_hidden : bool

#==========Onready Variables==========#
onready var anim : AnimatedSprite = $Anim
onready var animation_player : AnimationPlayer = $AnimationPlayer

#=========Functions==========#
func _ready():
	update_character()
	toggle_character(is_hidden, true)

#Must be called before adding this to the scene
func initialize(name : String, outfit : String, expression : String, position : String, hidden : bool = false) -> void:
	character_name = name
	current_outfit = outfit
	current_expression = expression
	current_position = position
	is_hidden = hidden
	
#Sets current animation and expression to the current variables
func update_character() -> void:
	anim.animation = character_name + "_" + current_outfit
	anim.frame = Data.expressions[current_expression]
	#toggle_character(is_hidden)
	
func change_outfit(outfit : String) -> void:
	current_outfit = outfit
	update_character()

func change_expression(expression : String) -> void:
	current_expression = expression
	update_character()

func play_animation(anim : String, backwards : bool = false) -> void:
	if backwards:
		animation_player.play_backwards(anim)
	else:
		animation_player.play(anim)

func remove_character(has_fade : bool = true) -> void:
	if has_fade:
		play_animation("Fade", true)
		yield(animation_player, "animation_finished")
	queue_free()

func toggle_character(hidden : bool, forced : bool = false, instant : bool = false) -> void:
	if hidden == is_hidden and not forced:
		return
	
	is_hidden = hidden
	if instant:
		animation_player.playback_speed = 64
	else:
		animation_player.playback_speed = 1
		
	if hidden:
		play_animation("Fade", true)
	else:
		#self.show()
		play_animation("Fade")
