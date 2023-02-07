extends Node2D

#==========Onready Variables==========#
onready var id_line_edit = $IDLineEdit

#==========Connected Functions==========#
func _on_OkButton_pressed():
	Global.user_data["SchoolID"] = id_line_edit.text
	Global.save_user_data()
	Global.switch_scene("MainMenu")
