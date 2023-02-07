extends Node

#==========Variables==========#
var words : Array = []
var difficulty_letters : Array = []
var combination_difficult_letters : Array = []
var random_words : Array = []

#==========Onready Variables==========#
onready var rand : RandomNumberGenerator = RandomNumberGenerator.new()

#==========Functions==========#
func _ready() -> void:
	rand.randomize()
	load_words()
	init()

func init() -> void:
	###TESTING (Gets difficult letters with 50% accuracy)
	WordList.reload_difficulty_letters()
	###20% chance of getting nonsense words
	WordList.fill_random_words_with_difficult_letters(180, 20, 13)#(80, 20, 13)
	print(random_words)

func reload_difficulty_letters() -> void:
	###TESTING
	difficulty_letters = Global.get_difficulty_letters()
	#difficulty_letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
	#difficulty_letters = ["a","c","e","h","i","b","r"]
	#difficulty_letters = []
	print("Difficult Letters: ", difficulty_letters)

func Combination(a : Array, reqLen : int, start : int, currLen : int, check : Array, length : int, resultArr : Array = []) -> Array:
	if currLen > reqLen:
		return resultArr
	
	elif currLen == reqLen:
		var tmp = []
		for i in range(0, length):
			if check[i]:
				tmp.append(a[i])
		resultArr.append(tmp)
		return resultArr
		
	if start == length:
		return resultArr
		
	check[start] = true
	Combination(a, reqLen, start + 1, currLen + 1, check, length, resultArr)
	
	check[start] = false
	Combination(a, reqLen, start + 1, currLen, check, length, resultArr)
	return resultArr

func fill_random_words_with_difficult_letters(size : int, non_sense_size : int = 0, max_word_length : int = -1) -> void:
	var max_letters : int = 3

	if difficulty_letters.size() < max_letters:
		max_letters = difficulty_letters.size()

	var check : Array = []
	for i in range(0, difficulty_letters.size()):
		check.append(false)
	combination_difficult_letters = Combination(difficulty_letters, max_letters, 0, 0, check, difficulty_letters.size())
	
	var get_rand_comb : bool = true
	var rand_combination_index = -1
	random_words = []
	while random_words.size() < size:
		var rand_index = rand.randi_range(0, words.size()-1)
		if get_rand_comb:
			rand_combination_index = rand.randi_range(0, combination_difficult_letters.size()-1)
			get_rand_comb = false
		var selected_word = words[rand_index]
		var good_word = true
		#print("Selected comb:",combination_difficult_letters[rand_combination_index])
		#print("Checking word:", selected_word)
		if max_word_length != -1:
			if selected_word.length() > max_word_length:
				continue
		for l in combination_difficult_letters[rand_combination_index]:
			if not (l in selected_word):
				good_word = false
		if not Global.check_if_word_is_valid(selected_word):
			good_word = false
		if good_word:
			random_words.append(selected_word)
			get_rand_comb = true
			#print("Word", selected_word, "is good")
	
	#insert nonsense words
	if difficulty_letters.size() <= 0:
		return
	var count : int = 0
	while count < non_sense_size:
		var non_sense_word = ""
		var rand_length = rand.randi_range(5, 9)
		for i in range(rand_length):
			non_sense_word += difficulty_letters[rand.randi_range(0, difficulty_letters.size()-1)]
		random_words.append(non_sense_word)
		count += 1
	
func load_words() -> void:
	var file = File.new()
	file.open("res://assets/words.txt", file.READ)
	while not file.eof_reached(): # iterate through all lines until the end of file is reached
		var line = file.get_line()
		words.append(line.to_lower())
	file.close()
	print("Loaded ", words.size(), " words")

func get_prompt(not_starting_with : Array = []) -> String:
	if not_starting_with.size() > 0:
		var loop = true
		while loop:
			var good_word = true
			var selected_word = random_words[rand.randi_range(0, random_words.size()-1)]
			for l in not_starting_with:
				if selected_word[0] == l:
					good_word = false
					break
			if good_word:
				loop = false
				return selected_word
	return random_words[rand.randi_range(0, random_words.size()-1)]
