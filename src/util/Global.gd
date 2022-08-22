extends Node

#==========Constant Variables==========#
const save_path = "user://save.dat"

#=========Other Variables==========#
#This is being used in save_data and load_data function
var user_data = {
	"Music" : 100,
	"Sfx" : 100,
	"Coins" : 0,
	"WPM" : 0.0,
	"Accuracy" : 0.0,
	"WordMastery" : {},
	"LetterMastery" : {},
	"Items" : [],
	"SavedProgress" : {},
}
#=========Functions==========#
#Insert here the scenes you want to add and to switch
func switch_scene(scene) -> void:
	pass

func save_user_data() -> void:
	var file = File.new()
	var error = file.open(save_path, File.WRITE)
	if error == OK:
		file.store_var(user_data)
		file.close()
		print("Data Successfully Saved")
	else:
		print("Error opening file")

func load_user_data() -> void:
	var file = File.new()
	var error = file.open(save_path, File.READ)
	if error == OK:
		user_data = file.get_var()
		file.close()
		print("Data Successfully Loaded")
	else:
		print("Error opening file")

func delete_user_data() -> void:
	set_default_user_data()
	var dir = Directory.new()
	if dir.file_exists(save_path):
		dir.remove(save_path)
		print("Data Successfully Deleted")
	else:
		print("No saved data found!")

func set_default_user_data() -> void:
	user_data = {
		"Music" : 100,
		"Sfx" : 100,
		"Coins" : 0,
		"WPM" : 0.0,
		"Accuracy" : 0.0,
		"WordMastery" : {},
		"LetterMastery" : {},
		"Items" : [],
		"SavedProgress" : [],
	}

func add_user_data_story_progress(scene : String, scene_index : int, characters : Array, location : String):
	user_data["SavedProgress"]["scene"] = scene
	user_data["SavedProgress"]["scene_index"] = scene_index
	user_data["SavedProgress"]["characters"] = characters
	user_data["SavedProgress"]["location"] = location

func add_word_mastery(word : String) -> void:
	if !user_data["WordMastery"].has(word):
		user_data["WordMastery"][word] = 1
	else:
		user_data["WordMastery"][word] += 1

func check_first_time() -> bool:
	var file = File.new()
	var error = file.open(save_path, File.READ)
	#If saved data is not found, return false
	if error == OK:
		return false
	return true
