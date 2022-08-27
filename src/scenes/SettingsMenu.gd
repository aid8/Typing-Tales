extends Node2D

onready var audio_player = $AudioPlayer

func _on_MasterVolume_value_changed(value):
	pass # Replace with function body.


func _on_MusicVolume_value_changed(value):
	pass # Replace with function body.


func _on_SFXVolume_value_changed(value):
	pass # Replace with function body.



func _on_MainMenuButton_pressed():
	Global.switch_scene("MainMenu")


func _on_CreditsButton_pressed():
	Global.switch_scene("Credits")
