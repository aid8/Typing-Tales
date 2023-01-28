extends Node2D
#==========TODO==========#
#WHEN TILE IS BEING TYPED, HIGHLIGHT ALSO

#==========Variables==========#
var GAME_TIME = 60
var TILE_SPAWN = 5
var SCORE_MULTIPLIER = 1.25
var KEY_SCORE = 5
var POWERUP_TIMERS = {
	"green" : 10,
	"blue" : 10,
	"red" : 10,
}

var tiles = []
var current_character_index = -1
var active_tile = null
var first_tile = null

var score = 0

var powerups = {
	"green" : false, #Multiplier
	"blue" : false, #Slow timer
	"red" : false, #Fast tile spawn
}

var colors = {
	"green" : Color(0.376471,0.654902,0.376471,1),
	"blue" : Color(0.105882,0.4,0.611765,1),
	"red" : Color(0.768627,0.419608,0.419608,1),
}
#==========Onready Variables==========#
onready var starting_tile_position = $StartingTilePosition
onready var ysort = $YSort

onready var red_bar = $UI/RedBar
onready var blue_bar = $UI/BlueBar
onready var green_bar = $UI/GreenBar
onready var timer_label = $UI/TimerLabel
onready var score_label = $UI/ScoreLabel

onready var game_timer = $GameTimer
onready var green_timer = $GreenTimer
onready var blue_timer = $BlueTimer
onready var red_timer = $RedTimer

#==========Preload Variables==========#
onready var tile = preload("res://src/objects/challengemenu3/Tile.tscn")

#==========Functions==========#

func _ready():
	Global.current_menu = self
	init()
	create_tiles()

func _process(delta : float) -> void:
	timer_label.text = String(game_timer.time_left).pad_decimals(2)
	#Progress bars
	if powerups.green:
		green_bar.max_value = POWERUP_TIMERS.green
		green_bar.value = green_timer.time_left
	if powerups.blue:
		blue_bar.max_value = POWERUP_TIMERS.blue
		blue_bar.value = blue_timer.time_left
	if powerups.red:
		red_bar.max_value = POWERUP_TIMERS.red
		red_bar.value = red_timer.time_left
		
func init():
	game_timer.start(GAME_TIME)
	update_ui()

func update_ui():
	score_label.text = String(score)

func add_score(text_length : int):
	var comp = text_length * KEY_SCORE
	if powerups.green:
		comp *= SCORE_MULTIPLIER
	score += comp
	update_ui()

func create_tiles():
	var width = 125
	var height = 125
	var gap = 10
	var j = 0
	var k = 0
	for i in range(1, 17):
		var t = tile.instance()
		t.position.x = starting_tile_position.position.x + ((width + gap) * k)
		t.position.y = starting_tile_position.position.y + ((height + gap) * j) 
		if i % 4 == 0:
			j += 1
			k = -1
		k += 1
		ysort.add_child(t)
		tiles.push_back(t)

func get_tiles_starting_letters() -> Array:
	var texts = []
	for tile in tiles:
		var text = tile.get_prompt()
		if text.length() > 0:
			texts.append(text[0])
	return texts

func find_tile(typed_character : String):
	#for tile in tiles.get_children():
	for tile in tiles:
		var prompt = tile.get_prompt()
		var next_character = prompt.substr(0,1)
		
		if next_character == typed_character:
			print("found new enemy starting ", next_character)
			active_tile = tile
			current_character_index = 1
			active_tile.set_next_character(current_character_index)
			active_tile.toggle_highlight(true, "start")
			return

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
		if active_tile == null:
			find_tile(key_typed)
		else:
			var prompt = active_tile.get_prompt()
			var next_character = prompt.substr(current_character_index, 1)
			if key_typed == next_character and typed_event.unicode != 0:
				#print("success: ", key_typed)
				current_character_index += 1
				active_tile.set_next_character(current_character_index)
				if current_character_index == prompt.length():
					#print("done")
					current_character_index = -1
					#active_tile.damage()
					if first_tile == null:
						first_tile = active_tile
						first_tile.toggle_highlight(true, "end")
					else:
						#Do magic here
						if first_tile.get_current_color() == active_tile.get_current_color():
							#Check color and add score
							if active_tile.get_current_color() == colors.green:
								green_timer.start(POWERUP_TIMERS.green)
								powerups.green = true
							elif active_tile.get_current_color() == colors.blue:
								blue_timer.start(POWERUP_TIMERS.blue)
								powerups.blue = true
								game_timer.set_paused(true)
							else:
								red_timer.start(POWERUP_TIMERS.red)
								powerups.red = true
							add_score(prompt.length())
							
							if !powerups.red:
								first_tile.delayed_refresh_tile(TILE_SPAWN)
								active_tile.delayed_refresh_tile(TILE_SPAWN)
							else:
								first_tile.refresh_tile()
								active_tile.refresh_tile()
						else:
							first_tile.cancel_tile()
							active_tile.cancel_tile()
						active_tile.toggle_highlight(false)
						first_tile.toggle_highlight(false)
						first_tile = null
					active_tile = null
			#else:
				#if typed_event.scancode != KEY_SHIFT and typed_event.scancode != KEY_ESCAPE: 
					#print("incorrect %s, should be %s" % [key_typed, next_character])
					
#==========Connected Functions==========#
func _on_GameTimer_timeout():
	pass # Replace with function body.

func _on_GreenTimer_timeout():
	powerups.green = false

func _on_BlueTimer_timeout():
	powerups.blue = false
	game_timer.set_paused(false)

func _on_RedTimer_timeout():
	powerups.red = false

#Testing
func _on_TestButton_pressed():
	Global.switch_scene("MainMenu")
