extends Node2D
#==========NOTE==========#
#This pause menu is for challenges only, story is separate

#==========Variables==========#

#==========Onready Variables==========#
onready var bgm_slide : HSlider = $BGMSlide
onready var sfx_slide : HSlider = $SFXSlide

#==========Preload Variables==========#

#==========Functions==========#
func _ready():
	pass

func pause() -> void:
	bgm_slide.value = Global.user_data["Music"]
	sfx_slide.value = Global.user_data["Sfx"]
	get_tree().paused = true
	self.show()

#==========Connected Functions==========#
func _on_PauseResumeBtn_pressed():
	self.hide()
	get_tree().paused = false
	Global.play_sfx("Select")

func _on_MainMenuBtn_pressed():
	get_tree().paused = false
	Global.switch_scene("MainMenu")
	Global.play_sfx("Select")

func _on_BGMSlide_value_changed(value):
	BackgroundMusic.volume_db = value
	Global.user_data["Music"] = value

func _on_SFXSlide_drag_ended(value_changed):
	Global.user_data["Sfx"] = sfx_slide.value
	Global.play_sfx("Confirm")
