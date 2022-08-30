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
	},
	
	"school_classroom1-a_day" : {
		"Animation" : "Classroom",
		"Frame" : 0,
		"Location" : "Xenomium Academy, Classroom 1-A",
	},
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

#Transitions: Fade, Shards, Curtain, SpiralSquare, DiamondTilesCover, SpinningRectangle, Shade, Zip, HorizontalBars
#Character_Animations: UpDown, Shake
var dialogues = {
	"Scene 1" : [
		#Dialogue 1
		{	"character" : "Adrian",
			"outfit" : "Summer",
			"expression" : "open_blush",
			"location" : "dorm_livingroom_day",
			"location_tint" : "#414141",
			"dialogue" : "What Why are you even taking my presents?",
			"transition" : "Curtain",
			"position" : "LEFT",
		},
		#Dialogue 2
		{
			"character" : "Felix",
			"character_animation" : "UpDown",
			"outfit" : "Casual",
			"expression" : "frown",
			#"dialogue" : "What was I supposed to do when they gave it to me thinking I was you?",
			"dialogue" : "Why are you?",
			"transition" : "SpinningRectangle",
			"location" : "school_classroom1-a_day",
			"location_tint" : "#ffffff",
			"position" : "RIGHT",
		},
		#Dialogue 3
		{
			"character" : "Adrian",
			"character_animation" : "Shake",
			"expression" : "open",
			"transition" : "Shards",
			"location_tint" : "#b84545",
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
			"scene_animation" : {
				"animation" : "shake",
				"shake_strength" : 30.0,
				"shake_decay" : 5.0,
			},
			"show_selection_timer" : 10,
			"hide_characters" : true,
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
