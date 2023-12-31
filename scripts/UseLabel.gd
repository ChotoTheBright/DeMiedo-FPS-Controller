extends Label

onready var control = get_parent()
#onready var player = control.player
onready var player = get_tree().get_nodes_in_group("player")[0]
onready var useray = player.get_node("Head/Camera/Use")#("ViewportContainer/Viewport/Player/Head/Camera/Use")
onready var weapons = player.get_node("Head/Camera/WeaponManager")

var text_visible = false

func _process(_delta):
	var Target = useray.get_collider()
	if useray.get_collider() and useray.usetimer.is_stopped() and Target.is_in_group("Useable"):
		text = "Use"#Use" // Utilizar
		prompt("Use")
	elif useray.get_collider() and useray.usetimer.is_stopped() and Target.is_in_group("Throwable"):
		if useray.object_grabbed:
			weapons.disable_all_weapons()#switch_to_weapon_slot(0)
			pass
		else:
			text = "Grab"#Grab" // Agarra
			prompt("Grab")
	else:
		unprompt()

func prompt(text): #
	if not text_visible:
		text = text
		text_visible = true

func unprompt():
	if text_visible:
		text_visible = false
		text = " "

