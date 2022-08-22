extends Node2D

#==========Variables==========#
var character_name : String
var current_outfit : String
var current_expression : String
var current_position : String
var is_hidden : bool

#==========Onready Variables==========#
onready var anim : AnimatedSprite = $Anim

#=========Functions==========#
func _ready():
	update_character()

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
	toggle_character(is_hidden)

func change_outfit(outfit : String) -> void:
	current_outfit = outfit
	update_character()

func change_expression(expression : String) -> void:
	current_expression = expression
	update_character()

func toggle_character(hidden : bool) -> void:
	is_hidden = hidden
	if hidden:
		self.hide()
	else:
		self.show()
