extends Node

onready var _timer = $Timer
onready var counter = 0
onready var player = get_tree().get_nodes_in_group("player")[0]
onready var control = get_tree().get_nodes_in_group("level_map")[0]
onready var player_camera = player.get_node("Head/Camera")
onready var Statsdisplay = get_tree().get_nodes_in_group("statsdisplay")[0]
onready var xhair = control.get_node("Crosshair")
onready var readytoend = false
onready var gracias# = control.get_node("GraciasPorJugar")
onready var thanks# = control.get_node("ThanksForPlaying")

func _ready():
	#Seem to have resolved the scalling issue! :D -- 10/6/23
#	control.viewport.size = get_viewport().size * 2.0
	player.global_transform = $PlayerSpawn.global_transform
	player_camera.get_node("WeaponManager")._canattack = false
#	player.is_start = true
#	control.statsscreen.visible = true#control.get_node("STATS").visible = true
	_timer.start()
	Statsdisplay.visible = false
	xhair.visible = false
	update_map_stats()


func returntomenu() -> void:
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scene2.tscn")

func _process(_delta):
	if readytoend == true:
		counter += 1 #<---- this is how the screen goes back to the start.
		if counter > 600: #5 seconds?
#			print("is this going off?")
			returntomenu()

func update_map_stats():
	control.kill_label.text = "Kills: " + str(control.killstally) + " // " + str(control.enemycount)
	control.secret_label.text = "Secrets: " + str(control.secretstally) + " // " + str(control.secretcount)

func fadetothanks():
	readytoend = true
	gracias.visible = true
	thanks.visible = true
	control.fadeplay.play("statsfade")
