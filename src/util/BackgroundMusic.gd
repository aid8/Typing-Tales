extends AudioStreamPlayer

#==========Variables==========#
var current_music : String = ""

#==========Functions==========#
func _ready():
	pass # Replace with function body.

func play_music(music : String) -> void:
	#fade if music is not the smae
	if !Data.bgms.has(music) or current_music == music:
		if current_music == music and !self.playing:
			self.play()
		return
	current_music = music
	self.stream = load(Data.bgms[music])
	self.play()

func stop_music() -> void:
	self.stop()
