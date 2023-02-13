extends Node
#==========TODO==========#

#==========Constant Variables==========#
const save_path : String = "user://save.dat"

#=========Other Variables==========#
#This is being used in save_data and load_data function
var user_data : Dictionary = {}
var current_menu : Node2D
var load_slot_index_selected : int = -1
var is_testing : bool = true

onready var http_request : HTTPRequest

#==========Preload Variables==========#
onready var rand : RandomNumberGenerator = RandomNumberGenerator.new()
onready var inform_menu = preload("res://src/ui/InformMenu.tscn")
onready var yes_no_menu = preload("res://src/ui/YesNoMenu.tscn")
onready var sfx = preload("res://src/util/SoundEffects.tscn")

#=========Functions==========#
func _ready():
	#Add http request
	http_request = HTTPRequest.new()
	add_child(http_request)
	
	if check_first_time():
		set_default_user_data()
	else:
		load_user_data()
	
	print(Global.user_data.SavedDataResearch)
	print(Global.get_total_day_and_session_time(Time.get_date_string_from_system()))

#Insert here the scenes you want to add and to switch
func switch_scene(scene) -> void:
	var scene_path
	match scene:	
		"StoryMode":
			scene_path = "Test"
		"MainMenu":
			scene_path = "MainMenu"
		"Challenge1":
			scene_path = "challenges_menu/ChallengeMenu1"
		"Challenge2":
			scene_path = "challenges_menu/ChallengeMenu2"
		"Challenge3":
			scene_path = "challenges_menu/ChallengeMenu3"
		"Challenge4":
			scene_path = "challenges_menu/ChallengeMenu4"
		"Challenge5":
			scene_path = "challenges_menu/ChallengeMenu5"
		"Credits":
			scene_path = "CreditsScene"
		"Disclaimer":
			scene_path = "DisclaimerMenu"
		"IDInput":
			scene_path = "IDInputMenu"
	SceneTransition.switch_scene("res://src/scenes/" + scene_path + ".tscn");
	BackgroundMusic.stop_music()

func save_user_data() -> void:
	var file = File.new()
	var error = file.open(save_path, File.WRITE)
	if error == OK:
		#file.store_var(user_data)
		file.store_line(to_json(user_data))
		file.close()
		print("Data Successfully Saved")
	else:
		print("Error opening file")

func load_user_data() -> void:
	var file = File.new()
	var error = file.open(save_path, File.READ)
	if error == OK:
		#user_data = file.get_var()
		user_data = parse_json(file.get_line())
		file.close()
		print("Data Successfully Loaded")
	else:
		print("Error opening file, creating a new file")
		set_default_user_data()

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
		"Name" : "Jo",
		"SchoolID" : "",
		"Music" : -25,
		"Sfx" : -20,
		"Coins" : 0,
		"WPM" : {"total_wpm": 0.0, "count" : 0},
		"Accuracy" : {"correct_count": 0.0, "wrong_count" : 0},
		"WordMastery" : {}, #"word" : {"total_accuracy" : x, "count" : x}
		"LetterMastery" : {}, #"letter" : {"wrong_count" : x, "correct_count" : x}
		#TESTING
		#"LetterMastery":{
		#	"a" : {"wrong_count" : 1, "correct_count" : 9},
		#	"b" : {"wrong_count" : 7, "correct_count" : 3},
		#	"c" : {"wrong_count" : 7, "correct_count" : 3},
		#	"z" : {"wrong_count" : 2, "correct_count" : 8},
		#},
		"Items" : [],
		"SavedProgress" : [{}, {}, {}, {}, {}, {}, {}, {}],
		"FinishedScenes" : {},
		"SavedDataResearch" : {
			#Dates are stored here
			"StoryMode"  : {},#{"1":{"time":0},"2":{"time":0},"3":{"time":0},"4":{"time":0},"5":{"time":0},"6":{"time":0}},
			"Challenge1" : {},
			"Challenge2" : {},
			"Challenge3" : {},
			"Challenge4" : {},
			"Challenge5" : {},
		}, #1st-7th day data collection of story and challenge modes
		"DataSent" : [false, false, false], #1st, 6th, and 7th day
		"TotalTimeSpent" : [0, 0, 0], #[Story mode, Challenge mode, Typing Time]
		"ChapterTimeSpent" : {}, #chapter_name : {"typing_time" : x, "total_time" : x}
		"SeenTutorials" : [false, false, false, false, false, false], #IF tutorials are already shown for challanges 1-5, 6 for story mode
		"ChallengeStats" : [
			{"wpm" : 0, "accuracy" : 0, "time" : 0, "play_count" : 0, "highest_score" : 0,}, 
			{"wpm" : 0, "accuracy" : 0, "time" : 0, "play_count" : 0, "highest_score" : 0,},
			{"wpm" : 0, "accuracy" : 0, "time" : 0, "play_count" : 0, "highest_score" : 0,},
			{"wpm" : 0, "accuracy" : 0, "time" : 0, "play_count" : 0, "highest_score" : 0,},
			{"wpm" : 0, "accuracy" : 0, "time" : 0, "play_count" : 0, "highest_score" : 0,},
		],
	}

func change_name(name : String) -> void:
	user_data["Name"] = name

func add_finished_scenes(scene : String) -> void:
	user_data["FinishedScenes"][scene] = true

func check_if_scene_is_finished(scene : String)-> bool:
	return user_data["FinishedScenes"].has(scene)

func add_user_data_story_progress(scene : String, scene_index : int, characters : Array, location : String, location_tint : String, save_date : String, image_path : String, bgm : String, index: int) -> void:
	user_data["SavedProgress"][index]["scene"] = scene
	user_data["SavedProgress"][index]["scene_index"] = scene_index
	user_data["SavedProgress"][index]["characters"] = characters
	user_data["SavedProgress"][index]["location"] = location
	user_data["SavedProgress"][index]["location_tint"] = location_tint
	user_data["SavedProgress"][index]["save_date"] = save_date
	user_data["SavedProgress"][index]["image_path"] = image_path
	user_data["SavedProgress"][index]["bgm"] = bgm

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

func get_mastered_words() -> Array:
	var result = []
	var word_mastery = user_data["WordMastery"]
	for word in word_mastery:
		if (word_mastery[word].total_accuracy / float(word_mastery[word].count)) >= Data.WORD_MASTERY_ACCURACY_BOUND and word_mastery[word].count >= Data.WORD_MASTERY_COUNT_BOUND:
			result.append(word.to_upper())
	print(word_mastery)
	result.sort()
	return result

#returns an array of letters which the user has difficulty with percentage parameter
func get_difficulty_letters(percentage : float = Data.LETTER_MASTERY_ACCURACY_BOUND) -> Array:
	var letters = []
	var letter_mastery = user_data["LetterMastery"]
	for i in letter_mastery:
		var l = letter_mastery[i]
		if (l.correct_count / float(l.wrong_count + l.correct_count)) < percentage:
			letters.append(i)
	return letters

func add_letter_mastery(letter : String, correct : bool, story : bool = true) -> void:
	#Dont include unnecessary letters
	if Data.unnecessary_characters.has(letter):
		return
	letter = letter.to_lower()
	if !user_data["LetterMastery"].has(letter):
		user_data["LetterMastery"][letter] = {"wrong_count" : 0, "correct_count" : 0}
	
	if correct:
		user_data["LetterMastery"][letter].correct_count += 1
		if story:
			user_data["Accuracy"].correct_count += 1
	else:
		user_data["LetterMastery"][letter].wrong_count += 1
		if story:
			user_data["Accuracy"].wrong_count += 1
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

#checks if word has unneccessary characters
func check_if_word_is_valid(word : String) -> bool:
	for c in Data.unnecessary_characters:
		if c in word:
			return false
	return true

func get_user_stats() -> Dictionary:
	var dict = {}
	#ADD WPM
	if user_data["WPM"].count > 0:
		dict["WPM"] = user_data["WPM"].total_wpm / float(user_data["WPM"].count)
	else:
		dict["WPM"] = 0
	
	#ADD ACCURACY
	if user_data["Accuracy"].correct_count + user_data["Accuracy"].wrong_count > 0:
		dict["Accuracy"] = user_data["Accuracy"].correct_count / float(user_data["Accuracy"].correct_count + user_data["Accuracy"].wrong_count)
	else:
		dict["Accuracy"] = 0
		
	#ADD LETTER DIFFICULTIES
	var difficult_letters = []
	for l in user_data["LetterMastery"]:
		var accuracy = user_data["LetterMastery"][l].correct_count / float (user_data["LetterMastery"][l].correct_count + user_data["LetterMastery"][l].wrong_count)
		print(l, "-", accuracy)
		if accuracy < Data.LETTER_MASTERY_ACCURACY_BOUND:
			difficult_letters.append(l)
	dict["Difficult_Letters"] = difficult_letters
	
	#ADD INDIVIDUAL LETTER STATS
	return dict

func setup_research_variables(mode : String, date : String) -> void:
	if !user_data["SavedDataResearch"][mode].has(date):
		user_data["SavedDataResearch"][mode][date] = {}
		user_data["SavedDataResearch"][mode][date]["WPM"] = 0.0
		user_data["SavedDataResearch"][mode][date]["Accuracy"] = 0.0
		user_data["SavedDataResearch"][mode][date]["time"] = 0.0
		user_data["SavedDataResearch"][mode][date]["play_count"] = 0

func save_research_variables(mode : String, date : String, wpm : float, accuracy : float, time : float) -> void:
	if !user_data["SavedDataResearch"][mode].has(date):
		print("Current date is invalid!")
		return
	user_data["SavedDataResearch"][mode][date]["WPM"] += wpm
	user_data["SavedDataResearch"][mode][date]["Accuracy"] += accuracy
	user_data["SavedDataResearch"][mode][date]["time"] += time
	user_data["SavedDataResearch"][mode][date]["play_count"] += 1
	#print(user_data)

func send_data(type : String, name : String, date : String, wpm : float, accuracy : float, other_info : String = "") -> void:
	var http = HTTPClient.new()
	
	var data = {
		Data.FORM_ENTRY_CODES["test_type"] : type,
		Data.FORM_ENTRY_CODES["name"] : name, 
		Data.FORM_ENTRY_CODES["date"] : date,
		Data.FORM_ENTRY_CODES["wpm"] : wpm,
		Data.FORM_ENTRY_CODES["accuracy"] : accuracy, 
		Data.FORM_ENTRY_CODES["other_info"] : other_info,
	}
	var pool_headers = PoolStringArray(Data.HTTP_HEADERS)
	data = http.query_string_from_dict(data)
	var result = http_request.request(Data.URLFORM, pool_headers, false, HTTPClient.METHOD_POST, data)
	
	if type == "PRE_TEST" and !user_data["DataSent"][0]: #1st day
		user_data["DataSent"][0] = true
	elif type == "TEST" and !user_data["DataSent"][1]: #6th day
		user_data["DataSent"][1] = true
		print("OK TEST")
	elif type == "POST_TEST" and !user_data["DataSent"][2]: #7th day
		user_data["DataSent"][2] = true
	print("ALREADY SENT, ", result)
	
func set_seen_tutorial(challenge_num : int) -> void:
	user_data["SeenTutorials"][challenge_num] = true

func register_challenge_stats(challenge_num : int, wpm : float, accuracy : float, time : float, score : float) -> void:
	user_data["ChallengeStats"][challenge_num]["wpm"] += wpm
	user_data["ChallengeStats"][challenge_num]["accuracy"] += accuracy
	user_data["ChallengeStats"][challenge_num]["time"] += time
	user_data["ChallengeStats"][challenge_num]["play_count"] += 1
	user_data["ChallengeStats"][challenge_num]["highest_score"] = max(score, Global.user_data["ChallengeStats"][challenge_num]["highest_score"])
	user_data["TotalTimeSpent"][1] += time

#if date is empty, this will get the overall time
func get_total_day_and_session_time(date : String = "") -> Dictionary:
	var total : float = 0
	var day : int = 1
	var cur_day : int = 1
	var dates : Array = []
	var story_time : float = 0
	var challenge_time : float = 0
	for mode in user_data["SavedDataResearch"]:
		for d in user_data["SavedDataResearch"][mode]:
			if date == "":
				total += user_data["SavedDataResearch"][mode][d].time
			if !dates.has(d):
				dates.push_back(d)
		if date == "":
			continue
		if user_data["SavedDataResearch"][mode].has(date):
			total += user_data["SavedDataResearch"][mode][date].time
			if mode == "StoryMode":
				story_time += user_data["SavedDataResearch"][mode][date].time
			else:
				challenge_time += user_data["SavedDataResearch"][mode][date].time
	dates.sort()
	if dates.size() > 0:
		day = Global.get_num_of_days_between_two_dates(dates[0], dates[dates.size()-1]) 
		cur_day = Global.get_num_of_days_between_two_dates(dates[0], Time.get_date_string_from_system()) + 1
	return {"day" : day, "time" : total, "cur_day" : cur_day, "story_time" : story_time, "challenge_time" : challenge_time}

func get_stats() -> Dictionary:
	var stats : Dictionary = {}
	stats["OverallWPM"] = 0
	stats["OverallAccuracy"] = 0
	if user_data["WPM"].count > 0:
		stats["StoryWPM"] = user_data["WPM"].total_wpm / user_data["WPM"].count
		stats["OverallWPM"] = stats["StoryWPM"]
	else:
		stats["StoryWPM"] = 0
	if user_data["Accuracy"].correct_count + user_data["Accuracy"].wrong_count > 0:
		stats["StoryAccuracy"] = user_data["Accuracy"].correct_count / float(user_data["Accuracy"].correct_count + user_data["Accuracy"].wrong_count)
		stats["OverallAccuracy"] = stats["StoryAccuracy"]
	else:
		stats["StoryAccuracy"] = 0
	stats["PlayTime"] = user_data["TotalTimeSpent"][0] + user_data["TotalTimeSpent"][1]
	stats["TypingTime"] = user_data["TotalTimeSpent"][2]
	
	var total_challenge_wpm : float = 0
	var total_challenge_accuracy : float = 0
	var count : int = 0
	for i in range (0, 5):
		var a = user_data["ChallengeStats"][i]
		stats["ChallengeStats" + String(i+1)] = [0, 0, a.play_count]
		if a.play_count > 0:
			stats["ChallengeStats" + String(i+1)][0] = a.wpm / float(a.play_count)
			stats["ChallengeStats" + String(i+1)][1] = a.accuracy / float(a.play_count)
			total_challenge_wpm += stats["ChallengeStats" + String(i+1)][0]
			total_challenge_accuracy += (stats["ChallengeStats" + String(i+1)][1] / 100)
			count += 1
	
	if count > 0:
		stats["OverallWPM"] += total_challenge_wpm / float(count)
		stats["OverallAccuracy"] += total_challenge_accuracy / float(count)
		if stats["StoryWPM"] != 0 and stats["StoryAccuracy"] != 0:
			stats["OverallWPM"] /= 2
			stats["OverallAccuracy"] /= 2
	
	return stats

func get_stats_on_date(date : String) -> Dictionary:
	var stats = {
		"StoryWPM" : 0,
		"StoryAccuracy" : 0,
		"ChallengeWPM" : 0,
		"ChallengeAccuracy" : 0,
		"OverallWPM" : 0,
		"OverallAccuracy" : 0,
	}
	
	var story_play_count = user_data["SavedDataResearch"]["StoryMode"][date]["play_count"]
	if story_play_count > 0:
		stats["StoryWPM"] = user_data["SavedDataResearch"]["StoryMode"][date]["WPM"] / float(story_play_count)
		stats["StoryAccuracy"] = (user_data["SavedDataResearch"]["StoryMode"][date]["Accuracy"] / float(story_play_count)) * 100
		
	var challenge_play_count = 0
	for mode in user_data["SavedDataResearch"]:
		if mode != "StoryMode":
			if user_data["SavedDataResearch"][mode].has(date):
				stats["ChallengeWPM"] += user_data["SavedDataResearch"][mode][date]["WPM"]
				stats["ChallengeAccuracy"] += user_data["SavedDataResearch"][mode][date]["Accuracy"]
				challenge_play_count += user_data["SavedDataResearch"][mode][date]["play_count"]
	if challenge_play_count > 0:
		stats["ChallengeWPM"] /= float(challenge_play_count)
		stats["ChallengeAccuracy"] /= float(challenge_play_count)
		
	if user_data["SavedDataResearch"]["StoryMode"][date].play_count == 0:
		stats["OverallWPM"] = stats["ChallengeWPM"]
		stats["OverallAccuracy"] = stats["ChallengeAccuracy"]
	elif challenge_play_count == 0:
		stats["OverallWPM"] = stats["StoryWPM"]
		stats["OverallAccuracy"] = stats["StoryAccuracy"]
	else:
		stats["OverallWPM"] = (stats["StoryWPM"] + stats["ChallengeWPM"]) / float(2)
		stats["OverallAccuracy"] = (stats["StoryAccuracy"] + stats["ChallengeAccuracy"]) / float(2)
	return stats

func create_popup(info : String, menu : Node2D, func_name : String = "") -> void:
	var x = inform_menu.instance()
	if func_name != "":
		x.connect("popup_confirmed", menu, func_name)
	x.init(info)
	menu.add_child(x)
	
func create_yes_no_popup(info : String, menu : Node2D, func_name_yes : String = "", func_name_no : String = "") -> void:
	var x = yes_no_menu.instance()
	if func_name_yes != "":
		x.connect("yes_confirmed", menu, func_name_yes)
	if func_name_no != "":
		x.connect("no_confirmed", menu, func_name_no)
	x.init(info)
	menu.add_child(x)

func has_saved_story_data() -> bool:
	var x = user_data["SavedProgress"]
	for i in range(0, x.size()):
		if x[i].size() > 0:
			return true
	return false

func play_sfx(sfx_name) -> void:
	var s = sfx.instance()
	s.load_sfx(sfx_name)
	BackgroundMusic.add_child(s)

func play_keyboard_sfx() -> void:
	var s = sfx.instance()
	var x = rand.randi() % 4
	s.load_sfx("Key" + String(x+1))
	BackgroundMusic.add_child(s)

#YYYY-MM-DD
func get_num_of_days_between_two_dates(date1 : String, date2 : String) -> int:
	var d1_arr = date1.split("-", true)
	var d2_arr = date2.split("-", true)
	var t1 = OS.get_unix_time_from_datetime ( { "year": int(d1_arr[0]), "month": int(d1_arr[1]), "day":int(d1_arr[2]), "hour": 0, "minute": 0} )
	var t2 = OS.get_unix_time_from_datetime ( { "year": int(d2_arr[0]), "month": int(d2_arr[1]), "day":int(d2_arr[2]), "hour": 0, "minute": 0} )
	return int(round(abs(t1-t2) / 86400))

func add_chapter_time(chap_name : String, type : String, time : float) -> void:
	if user_data["ChapterTimeSpent"].has(chap_name):
		if user_data["ChapterTimeSpent"][chap_name].has(type):
			user_data["ChapterTimeSpent"][chap_name][type] += time
		else:
			user_data["ChapterTimeSpent"][chap_name][type] = time
	else:
		user_data["ChapterTimeSpent"][chap_name] = {type : time}
	if type == "typing_time":
		user_data["TotalTimeSpent"][2] += time

func format_time(time : float) -> String:
	var mins = int(time) / 60
	time -= mins * 60
	var secs = int(time) 
	var zer = ""
	if secs < 10:
		zer = "0"
	return str(mins) + ":" + zer + str(secs)

func check_first_time() -> bool:
	var file = File.new()
	var error = file.open(save_path, File.READ)
	#If saved data is not found, return false
	if error == OK:
		return false
	return true
