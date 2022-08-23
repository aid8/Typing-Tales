extends Node

var characters = {
	#Character 1
	"Adrian" : {
		"ImagePath" : "",
	},
	#Character 2
	"Felix" : {
		"ImagePath" : "", 
	},
}

var backgrounds = {
	"dorm_livingroom_day" : {
		"Animation" : "Livingroom",
		"Frame" : 0,
		"Location" : "Xenomium Academy, Male student Dormitory",
	}
}

var expressions = {
	"frown" : 0,
	"frown_blush" : 1,
	"open" : 2,
	"open_blush" : 3,
	"smile" : 4,
	"smile_blush" : 5,
}

#Add more if there are characters that should not be included
var unnecessary_characters =  [".",",",":","?"," "]

#Words that have (word_mastery_accuracy_bound) 80% mastery that is typed more than or equal to (word_mastery_cound_bound)1 times will be ignored in story mode
var word_mastery_accuracy_bound = 0.80
var word_mastery_count_bound = 1

var dialogues = {
	"Scene 1" : [
		#Dialogue 1
		{	"character" : "Adrian",
			"outfit" : "Summer",
			"expression" : "open_blush",
			"location" : "dorm_livingroom_day",
			"dialogue" : "Why are you even taking my presents?",
			"position" : "LEFT",
		},
		#Dialogue 2
		{
			"character" : "Felix",
			"outfit" : "Casual",
			"expression" : "frown",
			"dialogue" : "What was I supposed to do when they gave it to me thinking I was you?",
			"position" : "RIGHT",
		},
		#Dialogue 3
		{
			"character" : "Adrian",
			"expression" : "open",
			"dialogue" : "yeah is yeah what what is",
		},
		#Dialogue 4
		{
			"character" : "Narrator",
			"dialogue" : "Baby baby you're my sun and moon",
			"show_selection" : [
				["Yes, you are my sun", "Scene 1_Choice1"],
				["No, you are my moon", "Scene 1_Choice2"],
			],
			"hide_characters" : "true",
		},
	],
	
	"Scene 1_Choice1" : [
		{
			"character" : "Narrator",
			"dialogue" : "Wrong choice, dead end.",
		},
	],
	
	"Scene 1_Choice2" : [
		{
			"character" : "Narrator",
			"dialogue" : "Good choice, still dead end.",
		},
	],
}

var quests = [
	{
		"Type" : "Daily",
		"Desc" : "Type 5 words"
	}
]
