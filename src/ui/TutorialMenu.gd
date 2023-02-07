extends Node2D

#==========Variables==========#
var tutorial_texts : Array = []
var max_pages : int = 0
var cur_page : int = 0

#==========Onready Variables==========#
onready var left_label : Label = $LeftLabel
onready var right_label : Label = $RightLabel
onready var next_btn : TextureButton = $NextBtn
onready var prev_btn : TextureButton = $PrevBtn

#==========Preload Variables==========#

#==========Functions==========#
func _ready():
	pass

func start(challenge_num : int) -> void:
	if Global.user_data["SeenTutorials"][challenge_num]:
		return
	tutorial_texts = Data.TUTORIAL_TEXT[challenge_num]
	max_pages = tutorial_texts.size()
	move_slide(0)
	get_tree().paused = true
	self.show()

func move_slide(next : int) -> void:
	if next == 1:
		cur_page += 2
		if cur_page >= max_pages:
			close_menu()
			Global.play_sfx("Confirm")
			return
		prev_btn.show()
	
	elif next == -1:
		cur_page -= 2
		if cur_page <= 0:
			cur_page = 0
			prev_btn.hide()
		next_btn.get_node("Label").text = "NEXT"
	
	left_label.text = tutorial_texts[cur_page]
	if cur_page + 1 < max_pages:
		right_label.text = tutorial_texts[cur_page + 1]
	else:
		right_label.text = "END OF TUTORIAL"
	if cur_page + 2 >= max_pages:
		next_btn.get_node("Label").text = "FINISH"

func close_menu() -> void:
	get_tree().paused = false
	Global.current_menu.countdown_menu.start()
	self.hide()

#==========Connected Functions==========#
func _on_NextBtn_pressed():
	move_slide(1)
	Global.play_sfx("Select")

func _on_PrevBtn_pressed():
	move_slide(-1)
	Global.play_sfx("Select")
