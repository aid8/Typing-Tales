extends CanvasLayer

signal yes_confirmed
signal no_confirmed

#==========Variables==========#
var information : String

#==========Onready Variables==========#
onready var inform_label = $InformLabel

#==========Functions==========#
func _ready():
	inform_label.text = information

func init(info : String) -> void:
	information = info
	
#==========Connected Functions==========#
func _on_YesButton_pressed():
	emit_signal("yes_confirmed")
	Global.play_sfx("Select")
	queue_free()

func _on_NoButton_pressed():
	emit_signal("no_confirmed")
	Global.play_sfx("Select")
	queue_free()
