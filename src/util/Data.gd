extends Node

const MAX_CHAPTERS = 3
const ALTERNATIVE_CHAPTERS = [0, 1]
const LETTER_MASTERY_ACCURACY_BOUND = 0.90
#Words that have (word_mastery_accuracy_bound) 94% mastery that is typed more than or equal to (word_mastery_cound_bound) 100 times will be ignored in story mode
const WORD_MASTERY_ACCURACY_BOUND = 0.80 #0.94
const WORD_MASTERY_COUNT_BOUND = 10 #100

var characters = {
	#Character 1
	"Amy" : {
		"ImagePath" : "",
	},
	#Character 2
	"Beth" : {
		"ImagePath" : "", 
	},
	#Character 3
	"Meg" : {
		"ImagePath" : "",
	},
	"Laurie" : {
		"ImagePath" : "",
	},
}

var backgrounds = {
	#HOME
	"Home_Fireplace" : {
		"Animation" : "Home",
		"Frame" : 0,
		"Location" : "Home, Fireplace",
	},
	
	"Home_Attic" : {
		"Animation" : "Home",
		"Frame" : 1,
		"Location" : "Home, Attic",
	},
	
	"Home_Bedroom" : {
		"Animation" : "Home",
		"Frame" : 2,
		"Location" : "Home, Bedroom",
	},
	
	
	"Home_Fireplace1" : {
		"Animation" : "Home",
		"Frame" : 3,
		"Location" : "Home, Fireplace 2",
	},
	
	
	"Home_Garret_Stairs1":{
		"Animation" : "Home",
		"Frame" : 4,
		"Location" : "Home, Garret Stairs1",
	},
	
	"Home_Garret_Stairs":{
		"Animation" : "Home",
		"Frame" : 5,
		"Location" : "Home, Garret Stairs",
	},
	
	"Home_Outside":{
		"Animation" : "Home",
		"Frame" : 6,
		"Location" : "Home, Outside",
	},
	
	"Home_Kitchen":{
		"Animation" : "Home",
		"Frame" : 7,
		"Location" : "Home, Kitchen",
	},
	
	"Home_DiningRoom":{
		"Animation" : "Home",
		"Frame" : 8,
		"Location" : "Home, Dining Room",
	},
	
	"Laurence_Home":{
		"Animation" : "LaurenceHome",
		"Frame" : 0,
		"Location" : "Laurence Home, Living Room",
	},
	
	"Laurence_Home_Living_Room":{
		"Animation" : "LaurenceHome",
		"Frame" : 1,
		"Location" : "Laurence Home, Living Room",
	},
	
	"Laurence_Home_Study_Room":{
		"Animation" : "LaurenceHome",
		"Frame" : 2,
		"Location" : "Laurence Home, Grandpa Study Room",
	},
	
	#SCHOOL
	"School_Classroom1" : {
		"Animation" : "School",
		"Frame" : 0,
		"Location" : "School_Classroom1",
	},
	
	"School_Entrance" : {
		"Animation" : "School",
		"Frame" : 1,
		"Location" : "School Entrance",
	},
	
	"School_Hallway" : {
		"Animation" : "School",
		"Frame" : 2,
		"Location" : "School Hallway",
	},
	
	"School_library" : {
		"Animation" : "School",
		"Frame" : 3,
		"Location" : "School Library",
	},
	
	#OUTSIDE
	"School_sunrise" : {
		"Animation" : "Outside",
		"Frame" : 0,
		"Location" : "School Outside",
	},
	
	"Festival" : {
		"Animation" : "Outside",
		"Frame" : 1,
		"Location" : "Outside Festival",
	},
	
	"Convenience_Store_Outside" : {
		"Animation" : "Outside",
		"Frame" : 2,
		"Location" : "Convenience Store Outside",
	},
	
	#Fix this
	"Ball" : {
		"Animation" : "Outside",
		"Frame" : 1,
		"Location" : "Outside Ball",
	},
	
	"Slums" : {
		"Animation" : "Outside",
		"Frame" : 3,
		"Location" : "Slums Outside",
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
		#Ini dapat kaipuhan pag mashow ka palang ning bagong character (si mga may #important)
		#Maski dai na ang remove_character/remove_all_characters, pag nag lag saka ko gamiton
		#Note, na reset ni kada chapter so kaipuhan mo ulit specify si starting outfit, position, etc
		#Mayong duplicate keys digdi, show once lang dapat ang keys yan nang character, location, etc.
		{
			"character" : "Narrator",
			"dialogue" : "What do you want?",
			"skip_dialogue" : true,
			"show_selection" : [
				["I'm so glad you came before we began!", "Chapter 2", 33],
				["But we haven't had any breakfast yet!", "Chapter 2 Alt 1", 0],
			],
			"show_selection_timer" : 10,
			"dialogue_remark" : "sighed Meg.",
		},
		
		{
			"character" : "Meg", #Always important
			"location" : "", #Important sa starting dialouge kang chapter
			"outfit" : "Casual", #important pag bagong show kang character
			"position" : "LEFT", #important pag bagong show kang character
			"expression" : "Open", #important pag bagong show kang character
			"dialogue" : "Hello there!", #Always important 
			"dialogue_remark" : "sighed Meg.", #Optional
		},
		
		{
			"character" : "Meg",
			#"location" : "", #no need kung dai ma change
			#"outfit" : "Casual", #no need kung dai man ma change
			#"position" : "LEFT", #no need kung dai man ma change
			#"expression" : "Open", #no need kung dai man ma change
			"dialogue" : "I am Meg!",
			"show_selection" : [
				["I'm so glad you came before we began!", "Chapter 2", 33],
				["But we haven’t had any breakfast yet!", "Chapter 2 Alt 1", 0],
			],
			"show_selection_timer" : 10,
		},
		
		#Since bago man ini, kaipuhan man yan important
		{
			"character" : "Amy",
			#"location" : "", #no need kung dai ma change
			"outfit" : "Casual", #important
			"position" : "RIGHT", #important
			"expression" : "Open", #important
			"dialogue" : "Hello, I am Amy",
			"dialogue_remark" : "replied Amy.", #Optional
		},
		
		#Pag you, dapat mayo outfit, position, expression, magkakaeeror ni kung igwa
		{
			"character" : "You",
			"dialogue" : "And my name is [name].",
		},
		
		#Arog kani pag ma hide
		{
			"character" : "Narrator",
			"dialogue" : "The three greeted!",
			"hide_character" : ["Amy", "Meg"],
			#"hide_all_characters" : true, #Pwede man ni kung gabos
			"skip_dialogue" : true,
		},
		
		#Tigswitch ko digdi si position ninda meg tas amy
		#And tigdagdag ko si laurie
		{
			"character" : "Meg",
			#Ini gagamiton mo kung dai pa siya na show/introduce previously
			"show_more_characters" : [
				{
					"character" : "Laurie",
					"outfit" : "Casual",
					"expression" : "Open_blush",
					"position" : "MIDDLE",
				},
				#Or kung gusto mo palitan si bako na current character ngunyan
				#Example digdi si meg baga nakafocus, kung gusto mo palitan kay Amy, pwede man ni
				{
					#Pero digdi gabos importante kaag ining 4, maski dai mo man papalitan
					"character" : "Amy",
					"outfit" : "Casual", #Dai ko man gusto palitan pero kaipuhan yaon ni digdi, pag digdi lang sa show_more_characters
					"expression" : "Frown", #Gusto ko palitan expression ni amy digdi, since naka focus kay meg, arog dapat kani
					"position" : "LEFT", #Gusto ko palitan position ni amy digdi, since naka focus kay meg, arog dapat kani
				},
			],
			"show_character" : ["Amy", "Meg"],
			"position" : "RIGHT", #need ta gusto ko ichange
			"dialogue" : "Hello there Laurie!",
		},
		
		#Since tigshow mo naman si laurie previously dai naman neeed si iba kung dai man babagohon
		{
			"character" : "Laurie",
			#"outfit" : "Casual", #no need kung dai man ma change
			#"position" : "LEFT", #no need kung dai man ma change
			#"expression" : "Open", #no need kung dai man ma change
			"dialogue" : "Yow, byebye",
			#Bako dapat digdi ang hide ta mawawara na si laurie pakasabi niya byebye
		},
		
		{
			"character" : "Narrator",
			"dialogue" : "This is Beth and Amy",
			"show_more_characters" : [
				{
					"character" : "Beth",
					"outfit" : "Casual",
					"expression" : "Open_blush",
					"position" : "LEFT",
				},
				{
					"character" : "Amy",
					"outfit" : "Casual",
					"expression" : "Frown",
					"position" : "RIGHT",
				},
			],
			"skip_dialogue" : true,
		},
		
		{
			"character" : "Amy",
			"dialogue" : "Wait!",
			"hide_character" : ["Laurie"],
		},
		
		{
			"character" : "Laurie",
			"show_character" : ["Laurie"],
			"dialogue" : "What?",
		},
		
		{
			"character" : "You",
			"dialogue" : "The one piece is real.",
		},
		
		{
			"character" : "You",
			"dialogue" : "The one piece is real.",
		}
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
	
	for i in range(1, ALTERNATIVE_CHAPTERS.size() + 1):
		for j in range(1, ALTERNATIVE_CHAPTERS[i-1] + 1):
			var file = File.new()
			file.open("res://assets/chapters/chapter" + String(i) + "Alt" + String(j) + ".json", file.READ)
			var text = file.get_as_text()
			var res = JSON.parse(text).result
			var chap_name = res.keys()[0]
			dialogues[chap_name] = res[chap_name] 
			file.close()
