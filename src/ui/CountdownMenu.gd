extends Node2D

#==========Onready Variables==========#
onready var timer_label = $TimerLabel
onready var countdown_timer = $CountdownTimer

#==========Functions==========#
func _ready():
	pass # Replace with function body.

func start(time : int = 3)-> void:
	get_tree().paused = true
	self.show()
	countdown_timer.start(time)

func _process(delta):
	timer_label.text = String(ceil(countdown_timer.time_left)).pad_decimals(0)

#==========Connected Functions==========#
func _on_CountdownTimer_timeout():
	get_tree().paused = false
	queue_free()
