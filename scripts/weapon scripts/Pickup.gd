extends Area
class_name Pickup
enum PICKUP_TYPES {SHOTGUN, AUTOMATIC, ROCKET_L,
	AUTOMATIC_AMMO, SHOTGUN_AMMO, ROCKET_L_AMMO, HEALTH, FOOD}
	
export(PICKUP_TYPES) var pickup_type
export var ammo = 20
export var rotating = false
export var is_food = false

onready var anim_player = $AnimationPlayer

func _ready():
	if rotating == true:
		anim_player.play("rotate")
