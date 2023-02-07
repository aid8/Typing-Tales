extends AudioStreamPlayer

#==========Variables==========#
var current_music : String = ""
var has_fade_in : bool = false
export var transition_duration = 1.00
export var transition_type = 1 # TRANS_SINE

#==========Onready Variables==========#
onready var tween_out = $TweenOut
onready var tween_in = $TweenIn

#==========Functions==========#
func _ready():
	pass # Replace with function body.

func play_music(music : String, fade_in : bool = false) -> void:
	#fade if music is not the smae
	if !Data.bgms.has(music):
		return
	elif current_music == music and !self.playing:
		self.play()
		return
	elif current_music != music and current_music != "":
		fade_out()
		has_fade_in = true
		current_music = music
		return
	
	current_music = music
	if fade_in:
		self.volume_db = -80
		fade_in()
	else:
		tween_out.stop_all()
		tween_in.stop_all()
		self.volume_db = Global.user_data["Music"]
		self.stream = load(Data.bgms[music])
		self.play()

func fade_out(reset_music : bool = false):
	# tween music volume down to 0
	if reset_music:
		current_music = ""
		has_fade_in = false
	tween_out.interpolate_property(self, "volume_db", Global.user_data["Music"], -80, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween_out.start()

func fade_in():
	self.stream = load(Data.bgms[current_music])
	self.play()
	tween_in.interpolate_property(self, "volume_db", -80, Global.user_data["Music"], transition_duration, transition_type, Tween.EASE_IN, 0)
	tween_in.start()

func stop_music(reset_music : bool = true) -> void:
	fade_out(reset_music)

func _on_TweenOut_tween_completed(object, key):
	object.stop()
	if has_fade_in:
		fade_in()

func _on_TweenIn_tween_completed(object, key):
	pass
