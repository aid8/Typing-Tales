extends Node

#==========Constant Variables==========#
const save_path : String = "user://save.dat"

#=========Other Variables==========#
#This is being used in save_data and load_data function
var user_data : Dictionary = {}

#=========Functions==========#
func _ready():
	set_default_user_data()

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
		"WPM" : {"total_wpm": 0.0, "count" : 0},
		"Accuracy" : 0.0,
		"WordMastery" : {}, #"word" : {"total_accuracy" : x, "count" : x}
		"LetterMastery" : {}, #"letter" : {"wrong_count" : x, "correct_count" : x}
		"Items" : [],
		"SavedProgress" : {},
		"FinishedScenes" : {},
	}

func add_finished_scenes(scene : String) -> void:
	user_data["FinishedScenes"][scene] = true

func check_if_scene_is_finished(scene : String)-> bool:
	return user_data["FinishedScenes"].has(scene)

func add_user_data_story_progress(scene : String, scene_index : int, characters : Array, location : String, location_tint : String) -> void:
	user_data["SavedProgress"]["scene"] = scene
	user_data["SavedProgress"]["scene_index"] = scene_index
	user_data["SavedProgress"]["characters"] = characters
	user_data["SavedProgress"]["location"] = location
	user_data["SavedProgress"]["location_tint"] = location_tint

func add_word_mastery(word : String, accuracy : float, check_word_if_valid : bool = false) -> void:
	word = format_word(word)
	#Check if word is in word database
	if !user_data["WordMastery"].has(word):
		user_data["WordMastery"][word] = {"total_accuracy" : accuracy, "count" : 1}
	else:
		user_data["WordMastery"][word].total_accuracy += accuracy
		user_data["WordMastery"][word].count += 1
	#print(user_data["WordMastery"])

#if empty dict is returned, word cannot be found
func get_word_mastery(word : String) -> Dictionary:
	var dict = {}
	var word_mastery = user_data["WordMastery"]
	if word_mastery.has(word):
		var count = word_mastery[word]["count"]
		dict["count"] = count
		dict["accuracy"] = word_mastery[word]["total_accuracy"] / float(count)
	return dict

func add_letter_mastery(letter : String, correct : bool) -> void:
	#Dont include unnecessary letters
	if Data.unnecessary_characters.has(letter):
		return
	letter = letter.to_lower()
	if !user_data["LetterMastery"].has(letter):
		user_data["LetterMastery"][letter] = {"wrong_count" : 0, "correct_count" : 0}
	
	if correct:
		user_data["LetterMastery"][letter].correct_count += 1
	else:
		user_data["LetterMastery"][letter].wrong_count += 1
	#print(user_data["LetterMastery"])

func add_overall_wpm(wpm : float):
	user_data["WPM"].total_wpm += wpm
	user_data["WPM"].count += 1

#Removes unnecessary letters in the word (e.g punctuations) and set all to lowercase
func format_word(word : String) -> String:
	for c in Data.unnecessary_characters:
		word = word.replace(c,"")
	word = word.to_lower()
	return word

func check_first_time() -> bool:
	var file = File.new()
	var error = file.open(save_path, File.READ)
	#If saved data is not found, return false
	if error == OK:
		return false
	return true
