extends CanvasLayer

onready var animation_player = $AnimationPlayer

signal transition_finished

func switch_scene(scene : String, type : String = "Fade") -> void:
	animation_player.play(type)
	yield(animation_player, "animation_finished")
	get_tree().change_scene(scene)
	animation_player.play_backwards(type)

func add_transition(type : String) -> void:
	animation_player.play(type)
	yield(animation_player, "animation_finished")
	emit_signal("transition_finished")
	animation_player.play_backwards(type)
