extends Node2D

const white : Color = Color(1, 1, 1)
const purple : Color = Color(0.850507, 0.550386, 0.933105)

var current_tab = "Main"

onready var main = $Main
onready var challenges = $Challenges
onready var main_buttons = [$Main/StoryModeButton, $Main/ChallengeModeButton, $Main/StatisticsMenuButton, $Main/SettingsMenuButton, $Main/QuitButton]

func _ready() -> void:
	switch_tab(current_tab)
	for i in range(0, 5):
		main_buttons[i].connect("mouse_entered", self, "change_button_label_color", [main_buttons[i], purple])
		main_buttons[i].connect("mouse_exited", self, "change_button_label_color", [main_buttons[i], white])

func switch_tab(tab : String) -> void:
	challenges.hide()
	main.hide()
	current_tab = tab
	
	if tab == "Main":
		main.show()
	elif tab == "Challenges":
		challenges.show()
	
	#To fix visual upon changing menus
	for i in range(0, 5):
		change_button_label_color(main_buttons[i], white)

func change_button_label_color(button, color) -> void:
	button.get_node("Label").set("custom_colors/font_color", color)

#=====Main Menu Functions=====#
func _on_StoryModeButton_pressed():
	Global.switch_scene("StoryMode")

func _on_ChallengeModeButton_pressed():
	switch_tab("Challenges")

func _on_StatisticsMenuButton_pressed():
	pass

func _on_SettingsMenuButton_pressed():
	pass

func _on_QuitButton_pressed():
	print("Application has been terminated")

#=====Challenges Functions=====#
func _on_Challenge1Button_pressed():
	Global.switch_scene("Challenge1")

func _on_Challenge1Button2_pressed():
	Global.switch_scene("Challenge2")

func _on_Challenge1Button3_pressed():
	Global.switch_scene("Challenge3")

func _on_Challenge1Button4_pressed():
	Global.switch_scene("Challenge4")

func _on_Challenge1Button5_pressed():
	Global.switch_scene("Challenge5")

func _on_BackButton_pressed():
	switch_tab("Main")
