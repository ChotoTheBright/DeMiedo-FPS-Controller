extends Area
#THIS IS FOR THE MACHETES
export var damage = 50
onready var player = get_tree().get_nodes_in_group("player")[0]
var bodies_to_exclude = []

func set_damage(_damage: int):
	damage = _damage
	
func set_bodies_to_exclude(_bodies_to_exclude: Array):
	bodies_to_exclude = _bodies_to_exclude

func fire():
	for body in get_overlapping_bodies():
		if body.has_method("hurt") and !body in bodies_to_exclude:
			body.hurt(damage, global_transform.origin.direction_to(body.global_transform.origin))
	for area in get_overlapping_areas():
		if area.has_method("hurt"):
			area.hurt(damage, global_transform.origin.direction_to(area.global_transform.origin))
			player.get_node("Audio/MacheteHitFX").play()
