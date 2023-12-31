extends Label

onready var etimer = get_node("NotifTimer")

const MAX_LINES = 2
var event_info = []
var event_num

func _ready():
# warning-ignore:standalone_expression
	text + ""


func event_text(event_number):
	etimer.start()
	match event_number:
		1:
			event_info.push_back("He has been banished...") #The way outside has opened....//Se ha abierto una puerta en otro lugar
		2:
			event_info.push_back("The bars in the floor are open...") #A door has opened nearby//Se ha abierto una puerta en otro lugar
		3:
			event_info.push_back("This door needs a key to open...")  
		4:
			event_info.push_back("...")
		5:
			event_info.push_back("The path is now clear...") #
		6:
			event_info.push_back("A secret door has opened elsewhere...")
		7:
			event_info.push_back("The chuch floor has moved...") #The floor has moved/El suelo ha desaparecido
		8:
			event_info.push_back("The skull door has opened...") #disappeared/El suelo ha desaparecido
		9:
			event_info.push_back("The last door has opened...")
		10:
			event_info.push_back("A Cursed Blood Jewel! Shoot it repeatedly!")#Shoot The Cursed Blood Jewel!!
		11:
			event_info.push_back("This door opens elsewhere...")
		12:
			event_info.push_back("The grate blocking the portal is open...")
		13:
			event_info.push_back("You found a secret area ! ")
		14:
			event_info.push_back("Press F for flashlight")
		15:
			event_info.push_back("Enter the blood well...")
		16:
			event_info.push_back("Two more to go...")
		17:
			event_info.push_back("One more to go...")
		18:
			event_info.push_back("Sequence Complete !")
		19:
			event_info.push_back("The path to the Temple is open...")
		20:
			event_info.push_back("The next floor up is accessible...")
		21:
			event_info.push_back("Behind you...")
		22:
			event_info.push_back("It must open somehow...")
		23:
			event_info.push_back("Offer yourself...")
		24:
			event_info.push_back("....")
	while event_info.size() >= MAX_LINES:
		event_info.pop_front()
	update_display()


func remove_event_info():
	if event_info.size() > 0:
		event_info.pop_front()
	update_display()


func update_display():
	text = ""
	for event_info_text in event_info:
		text += event_info_text + "\n"
