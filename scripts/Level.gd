extends Control

onready var viewport = $ViewportContainer/Viewport
onready var player = get_tree().get_nodes_in_group("player")[0]
onready var r_label = $RestartLabel
onready var player_head = player.get_node("Head")
onready var player_camera = player.get_node("Head/Camera")
onready var control = get_tree().get_nodes_in_group("level_map")[0]
onready var Statsdisplay = get_tree().get_nodes_in_group("statsdisplay")[0]
onready var scale_factor = 0.50 #This is to set the initial scale of the game
onready var spawn = $ViewportContainer/Viewport/LEVEL/PlayerSpawn

func _ready():
	randomize() 
	#randomize can be used for things like pain chances, etc.
	viewport.size = get_viewport().size * scale_factor
	# warning-ignore:return_value_discarded
	get_viewport().connect("size_changed", self, "_root_viewport_size_changed")
	_root_viewport_size_changed()

func _process(_delta):
	#RESTART IF DEAD
	if player.is_dead and Input.is_action_just_pressed("level_restart"):
		control.r_label.visible = false
		player.is_dead = false
		player.healthmanager.cur_health = 100
		Statsdisplay.update_health(player.healthmanager.cur_health)
		player.global_transform = spawn.global_transform

	#TELEPORT BACK TO START
	if player.global_transform.origin[1] < -70.0: reset_player_pos(Vector3(0.0, 8.0, 0.0))
	#Alternative method
#	if player.global_transform.origin[1] < -75.0:
#		player.global_transform = spawn.global_transform


func _root_viewport_size_changed():
	viewport.size = get_viewport().size * scale_factor

func scale_change(_factor):
	_factor = scale_factor
	viewport.size = get_viewport().size * scale_factor

func reset_player_pos(reset_pos : Vector3):
	player.global_transform.origin = reset_pos
	player.velocity = Vector3.ZERO
	player.rotation_degrees[1] = 0
	player_camera.rotation_degrees = Vector3.ZERO
	player_head.mouse_rotation_x = 0.0


func water_enter(body):
	if body.is_in_group("player"):
		player.in_water = true

func out_of_water(body):
	if body.is_in_group("player"):
		player.in_water = false




