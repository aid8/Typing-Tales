extends Node

const MAX_CHAPTERS = 1
const LETTER_MASTERY_ACCURACY_BOUND = 0.90
#Words that have (word_mastery_accuracy_bound) 94% mastery that is typed more than or equal to (word_mastery_cound_bound) 100 times will be ignored in story mode
const WORD_MASTERY_ACCURACY_BOUND = 0.80 #0.94
const WORD_MASTERY_COUNT_BOUND = 1 #100

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
		#Ini dapat kaipuhan pag mashow ka palang ning bagong character (si mga may #important)
		#Maski dai na ang remove_character/remove_all_characters, pag nag lag saka ko gamiton
		#Note, na reset ni kada chapter so kaipuhan mo ulit specify si starting outfit, position, etc
		#Mayong duplicate keys digdi, show once lang dapat ang keys yan nang character, location, etc.
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
