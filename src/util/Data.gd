extends Node

const MAX_CHAPTERS = 3
const LETTER_MASTERY_ACCURACY_BOUND = 0.90
#Words that have (word_mastery_accuracy_bound) 94% mastery that is typed more than or equal to (word_mastery_cound_bound) 100 times will be ignored in story mode
const WORD_MASTERY_ACCURACY_BOUND = 0.80 #0.94
const WORD_MASTERY_COUNT_BOUND = 1 #100

var characters = {
	#Character 1
	"Adrian" : {
		"ImagePath" : "",
	},
	#Character 2
	"Felix" : {
		"ImagePath" : "", 
	},
	#Character 3
	"Lucy" : {
		"ImagePath" : "",
	},
	"Alec" : {
		"ImagePath" : "",
	},
}

var backgrounds = {
	"Dorm_livingroom_day" : {
		"Animation" : "Home",
		"Frame" : 0,
		"Location" : "Xenomium Academy, Male student Dormitory",
	},
	
	"School_classroom1-a_day" : {
		"Animation" : "School",
		"Frame" : 0,
		"Location" : "Xenomium Academy, Classroom 1-A",
	},
	
	"School_entrance" : {
		"Animation" : "School",
		"Frame" : 1,
		"Location" : "Xenomium Academy, Entrance",
	},
	
	"School_hallway" : {
		"Animation" : "School",
		"Frame" : 2,
		"Location" : "Xenomium Academy, Hallway",
	},
	
	"School_library" : {
		"Animation" : "School",
		"Frame" : 3,
		"Location" : "Xenomium Academy, Library",
	},
	
	"School_sunrise" : {
		"Animation" : "Outside",
		"Frame" : 0,
		"Location" : "Xenomium Academy",
	},
}

var expressions = {
	"Frown" : 0,
	"Frown_blush" : 1,
	"Open" : 2,
	"Open_blush" : 3,
	"Smile" : 4,
	"Smile_blush" : 5,
	"Closed_frown" : 6,
	"Closed_frown_blush" : 7,
	"Closed_open" : 8,
	"Closed_open_blush" : 9,
	"Closed_smile" : 10,
	"Closed_smile_blush" : 11,
}

#Add more if there are characters that should not be included
var unnecessary_characters =  [".",",",":","?"," ","-"]

#Transitions: Fade, Shards, Curtain, SpiralSquare, DiamondTilesCover, SpinningRectangle, Shade, Zip, HorizontalBars
#Character_Animations: UpDown, Shake
var dialogues = {
	"Test" : [
		{
			"character" : "Narrator",
			"dialogue" : "I",
		},
		{
			"character" : "Narrator",
			"dialogue" : "I...",
		},
		{
			"character" : "Narrator",
			"dialogue" : "I LOVE You",
		},
		{
			"character" : "Narrator",
			"dialogue" : "Sorry, I love someone else",
		},
	]
}

var quests = [
	{
		"Type" : "Daily",
		"Desc" : "Type 5 words"
	}
]

func _ready():
	load_chapters()

func load_chapters():
	for i in range(1, MAX_CHAPTERS + 1):
		var file = File.new()
		file.open("res://assets/chapters/chapter" + String(i) + ".json", file.READ)
		var text = file.get_as_text()
		var res = JSON.parse(text).result
		var chap_name = res.keys()[0]
		dialogues[chap_name] = res[chap_name] 
		file.close()
