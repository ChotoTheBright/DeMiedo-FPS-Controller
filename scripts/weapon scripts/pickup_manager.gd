extends Area

signal got_pickup

var max_player_health = 0
var cur_player_health = 0
onready var pickupFX = get_parent().get_node("Audio/PickupFX")
#good for Large Pickups
onready var pickupFX2 = get_parent().get_node("Audio/PickupFX2")
#good for Small Pickups
onready var crunchFX = get_parent().get_node("Audio/CrunchFX")
#good for Food Pickups
onready var health = get_parent().get_node("HealthManagerPlayer")
onready var player = get_parent()

func update_player_health(_amnt):
	pass
	
func _ready():
	pass
	
func on_area_enter(pickup: Pickup):
	if pickup.pickup_type == Pickup.PICKUP_TYPES.HEALTH:
		if health.cur_health >= 100:
			return
		else:
			pickupFX.play()
			emit_signal("got_pickup", pickup.pickup_type, pickup.ammo)
			pickup.queue_free()
	elif pickup.pickup_type == Pickup.PICKUP_TYPES.FOOD:
		if health.cur_health >= 100:
			return
		else:
			crunchFX.play()
			emit_signal("got_pickup", pickup.pickup_type, pickup.ammo)
			pickup.queue_free()
	elif pickup.ammo == 1:
		pickupFX2.play()
		emit_signal("got_pickup", pickup.pickup_type, pickup.ammo)
		pickup.queue_free()
	else:
		pickupFX.play()
		emit_signal("got_pickup", pickup.pickup_type, pickup.ammo)
		pickup.queue_free()
