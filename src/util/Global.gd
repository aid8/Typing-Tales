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
}

#=========Functions==========#
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

func check_first_time() -> bool:
	var file = File.new()
	var error = file.open(save_path, File.READ)
	#If saved data is not found, return false
	if error == OK:
		return false
	return true
