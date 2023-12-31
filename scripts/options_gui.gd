extends Node

onready var game_res1 = get_tree().get_nodes_in_group("control")
onready var game_res2 = get_tree().get_nodes_in_group("viewport")
onready var gui_access = get_parent().get_parent().get_parent().get_node("GUILayer/VBoxContainer")
onready var environment = null

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	gui_access.visible = false


func _process(_delta):
	if get_tree().paused:
		gui_access.visible = true
	else:
		gui_access.visible = false



#func set_post_process(enabled: bool):
#	post_process_lcd.set_shader_param("enabled", enabled)
#	post_process_blur.set_shader_param("enabled", enabled)

#func set_color_depth(value: int):
#	post_process_dither_band.set_shader_param("col_depth", value)
#
#func set_dither_banding(enabled: bool):
#	post_process_dither_band.set_shader_param("dither_banding", enabled)
#
func set_fog_enabled(enabled: bool):
	environment.set_fog_enabled(enabled)

func set_fog_color(color: Color):
	environment.set_fog_color(color)

func set_fog_depth_begin(value: float):
	environment.set_fog_depth_begin(value)

func set_fog_depth_end(value: float):
	environment.set_fog_depth_end(value)

func set_ambient_light_color(color: Color):
	environment.set_ambient_light_color(color)

func set_ambient_energy(value: float):
#	environment.set_ambient_light_sky_contribution(value)
	environment.environment.set_ambient_light_sky_contribution(value)

