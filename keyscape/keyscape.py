import pystray
import PIL.Image
from pynput import keyboard
from win10toast import ToastNotifier

#==========FUNCTIONS==========#
def on_clicked(icon, item):
	global STARTING
	if str(item) == "Start":
		STARTING = True
		start_tracking()
		push_notification(NAME + " is now monitoring keywords")
		update_menu()
	elif str(item) == "Stop":
		STARTING = False
		stop_tracking()
		push_notification(NAME + " has stopped monitoring keywords")
		update_menu()
	elif str(item) == "Exit":
		stop_menu()

def start_menu(MENU_PICKED):
	global ICON
	ICON = pystray.Icon(NAME, IMAGE, menu=MENU_PICKED)
	ICON.run()

def stop_menu():
	global ICON
	if ICON != None:
		ICON.stop()
	add_word_on_file(CURRENT_WORD)

def update_menu():
	global ICON
	if ICON == None:
		return
	ICON.update_menu()

def push_notification(notif):
	global TOAST, NAME, ICON_FILE
	TOAST.show_toast(
		NAME,
	    notif,
	    duration = 5,
	    icon_path = ICON_FILE,
	    threaded = True,
	)

def start_tracking():
	global LISTENER
	LISTENER = keyboard.Listener(on_press=on_press)
	LISTENER.start()

def stop_tracking():
	global LISTENER
	if LISTENER == None:
		return
	LISTENER.stop()
	add_word_on_file(CURRENT_WORD)

def on_press(key):
	print(key)
	global CURRENT_WORD
	presented_key = str(key).replace('\'', '')
	if presented_key[0:3] == "Key":
		if presented_key == "Key.space" or presented_key == "Key.enter":
			add_word_on_file(CURRENT_WORD)
			CURRENT_WORD = ""
		if presented_key == "Key.backspace":
			if len(CURRENT_WORD) > 1:
				CURRENT_WORD = CURRENT_WORD[:-1]
	else:
		CURRENT_WORD += presented_key

def add_word_on_file(word):
	# We can modify here the word to remove numbers and letters
	global SAVE_FILE
	if word == "":
		return
	with open(SAVE_FILE, 'a') as logs:
		logs.write(word + "\n")

#==========VARIABLES==========#
NAME = "Keyscape"
SAVE_FILE = "words_tracked.txt"
ICON_FILE = "icon.ico"

IMAGE = PIL.Image.open(ICON_FILE)
STARTING = False
MENU = pystray.Menu(
	pystray.MenuItem("Start", on_clicked, enabled=lambda item: (not STARTING)),
	pystray.MenuItem("Stop", on_clicked, enabled=lambda item: STARTING),
	pystray.MenuItem("Exit", on_clicked)
)
ICON = None
LISTENER = None
TOAST = ToastNotifier()
CURRENT_WORD = ""

push_notification(NAME + " is running and stopped by default. Check system tray for more options.")
start_menu(MENU)