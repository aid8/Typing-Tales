extends Node

var characters = {
	#Character 1
	"Aid" : {
		"ImagePath" : "", 
	},
	#Character 2
	"Sam" : {
		"ImagePath" : "", 
	},
	#Character 3
	"Paps" : {
		"ImagePath" : "", 
	},
}

var dialogues = {
	"Scene 1" : [
		#Dialogue 1
		{	"character" : "Aid",
			"dialogue" : "Hello there! I am Aid",
		},
		#Dialogue 2
		{
			"character" : "Sam",
			"dialogue" : "Hi, I am Sam!",
		},
		#Dialogue 3
		{
			"character" : "Paps",
			"dialogue" : "Yo, I am Paps!",
		},
		#Dialogue 4
		{
			"character" : "Narrator",
			"dialogue" : "Baby baby you're my sun and moon",
			"show_selection" : [
				["Yes, you are my sun", "Scene 1_Choice1"],
				["No, you are my moon", "Scene 1_Choice2"],
			],
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
