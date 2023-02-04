extends CanvasLayer

signal popup_confirmed

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
func _on_OkButton_pressed():
	emit_signal("popup_confirmed")
	queue_free()
