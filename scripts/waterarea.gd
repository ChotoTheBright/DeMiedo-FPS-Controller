extends Area

export var is_blood = false
onready var player = get_tree().get_nodes_in_group("player")[0]
onready var _area = "hat"
onready var timer = $Timer

func timerreset():
	damageplayer(player.get_node("Hat"))

func damageplayer(area):
	if area.is_in_group("hat") and player.is_dead == false and is_blood == true:
		timer.start()
#			if body._submerged == true and body.bloodpowerup == true:
#				pass
		if player._submerged == true and player.bloodpowerup == false:
			player.choke(15.0,Vector3(1,1,1))
		else:
			pass
	else:
		timer.stop()
		pass
