extends Label

onready var Statsdisplay = get_tree().get_nodes_in_group("statsdisplay")[0]
const MAX_LINES = 5
var pickups_info = []

func _ready():
# warning-ignore:standalone_expression
	text + ""
	
func add_pickups_info(pickup_type, amount: int):
#	$RemoveInfoTimer.start()
	$PLTimer.start()
	
	match pickup_type:
		Pickup.PICKUP_TYPES.AUTOMATIC:
			pickups_info.push_back("Picked up Automático") #Picked up Automatic // Recogio el Automático
			Statsdisplay.intruder = false
		Pickup.PICKUP_TYPES.AUTOMATIC_AMMO:
			pickups_info.push_back(str(amount) + "  Automático Ammo") #Munición//"Picked up AUTOMATIC Ammo " + str(amount)
		Pickup.PICKUP_TYPES.SHOTGUN:
			pickups_info.push_back("You got the Super Shotgun!") #Recogio la escopeta super// 
			Statsdisplay.intruder = false
		Pickup.PICKUP_TYPES.SHOTGUN_AMMO:
			pickups_info.push_back(str(amount) + "  Shotgun Shells") #Caja de Balas Escopeta
		Pickup.PICKUP_TYPES.ROCKET_L:
			pickups_info.push_back("La Martilla Ardiente") #
			Statsdisplay.intruder = false
		Pickup.PICKUP_TYPES.ROCKET_L_AMMO:
			pickups_info.push_back(str(amount) + "  Toroxidados")
		Pickup.PICKUP_TYPES.HEALTH:
			pickups_info.push_back(str(amount) + "  Healing") #Curación //Healing
		Pickup.PICKUP_TYPES.FOOD:
			pickups_info.push_back("Tamales are good for you! (:") #Me gusta tamales

			
	while pickups_info.size() >= MAX_LINES:
		pickups_info.pop_front()
	update_display()

func remove_pickups_info():
	if pickups_info.size() > 0:
		pickups_info.pop_front()
	update_display()
	
func update_display():
	text = ""
	for pickups_info_text in pickups_info:
		text += pickups_info_text + "\n"
		
	
