extends Label

onready var _timer = $ILTimer
var notiftimer

const MAX_LINES = 2
var thought_info = []
var e_num

func _ready():
# warning-ignore:standalone_expression
	text + ""



func player_is_thinking(thought_number): #same as "add_pickups_info"
	_timer.start()
	match thought_number:
		PlayerThought.THOUGHT_NUM.t1:
			thought_info.push_back("You found a secret area ! ") #¡ Encontraste  un  área  secreta !
			#You found a secret área!
#			controller.secret_counter += 1
		PlayerThought.THOUGHT_NUM.t2:
			thought_info.push_back("Press F for flashlight") # Pulse F para linterna // ¡ El Dopefish vive !
			#////This door needs a key...
#			thoughtsound1.play()
		PlayerThought.THOUGHT_NUM.t3:
			thought_info.push_back("This door opens elsewhere") #The  front  gate  is  open/La  porton  principal  esta  abierta
#			thoughtsound1.play()
		PlayerThought.THOUGHT_NUM.t4:
			thought_info.push_back("Enter the blood well...") 
			#No going home now/You cant go home anymore/Ya no se puede volver a casa....
#			thoughtsound1.play()
		PlayerThought.THOUGHT_NUM.t5:
			thought_info.push_back("A Cursed Blood Jewel! Shoot it repeatedly!") #What's it for?//¿Para qué es esto?
#			thoughtsound1.play()
		PlayerThought.THOUGHT_NUM.t6:
			thought_info.push_back("This door needs a key") #Esta puerta necesita una Llave Esquelto
			#Esta puerta necesita una llave maestra...
#			thoughtsound1.play()
	while thought_info.size() >= MAX_LINES:
		thought_info.pop_front()
	update_display()


func remove_thoughts_info():
	if thought_info.size() > 0:
		thought_info.pop_front()
	update_display()


func update_display():
	text = ""
	for thoughts_info_text in thought_info:
		text += thoughts_info_text + "\n"
