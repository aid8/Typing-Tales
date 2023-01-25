extends KinematicBody2D

#==========Variables==========#
const type = "FallingObject"
onready var anim : AnimatedSprite = $Anim
var velocity : Vector2
var fall_speed : float = 0

#==========Functions==========#
func _ready():
	randomize_frame()
	velocity = Vector2(0, fall_speed)

func initialize(speed : float):
	fall_speed = speed

func _physics_process(delta):
	velocity = move_and_slide(velocity, Vector2(0, -1))

func randomize_frame() -> void:
	anim.frame =  randi() % anim.frames.get_frame_count("default")
