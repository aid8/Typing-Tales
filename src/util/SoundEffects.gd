extends AudioStreamPlayer

#==========Variables==========#

#==========Functions==========#
func _ready():
	pass

func load_sfx(sfx : String) -> void:
	if !Data.sfxs.has(sfx):
		return
	self.stream = load(Data.sfxs[sfx])
	self.volume_db = Global.user_data["Sfx"]

#==========Connected Functions==========#
func _on_SoundEffects_finished():
	queue_free()
