extends Node2D

func _on_StoryModeButton_pressed():
	Global.switch_scene("StoryMode")


func _on_ChallengeModeButton_pressed():
	Global.switch_scene("ChallengeMode")


func _on_StatisticsMenuButton_pressed():
	Global.switch_scene("StatisticsMenu")


func _on_SettingsMenuButton_pressed():
	Global.switch_scene("SettingsMenu")


func _on_QuitButton_pressed():
	print("Application has been terminated")
