extends Node2D

#==========Variables==========#
var heart_uis : Array = []
var lives : int = 5
var max_lives :int = 5

#==========Preload Variables==========#
onready var heart_ui = preload("res://src/objects/challengemenu1/HeartUI.tscn")

#==========Functions==========#
func _ready():
	pass

func init(ml : int) -> void:
	max_lives = ml
	lives = ml
	for i in range(0, ml):
		var h = heart_ui.instance()
		heart_uis.append(h)
		h.position = position
		h.position.x += i * 45
		add_child(h)

func subtract_life()-> void:
	if lives <= 0:
		return
	heart_uis[lives-1].frame = 1
	lives -= 1

func add_life()-> void:
	if lives >= max_lives:
		return
	heart_ui[lives].frame = 0
	
func get_lives() -> int:
	return lives
