extends Node

onready var control = get_tree().get_nodes_in_group("level_map")[0]
onready var player = get_tree().get_nodes_in_group("player")[0]
onready var gui_access = control.get_node("GUILayer/VBoxContainer")
onready var BG_gui_access_bdr = control.get_node("GUILayer/MenuBGBorder")
onready var environment = preload("res://default_env.tres")
onready var _crossh = control.get_node("Crosshair")
onready var _scale_factor = control.scale_factor
onready var optbut = $VBoxContainer/OptionsPanel/VBoxContainer/Render/OptionButton
onready var fs_toggle = $VBoxContainer/OptionsPanel/VBoxContainer/Fullscreen/CheckBox

func _ready():
	if OS.is_window_fullscreen(): fs_toggle.pressed = true
	pause_mode = PAUSE_MODE_PROCESS
	gui_access.visible = false
	BG_gui_access_bdr.visible = false
	_crossh.set_texture(_crossh.crosshair0)

	optbut.add_item("'Super Crunch'",0)
	optbut.add_item("Pixelation 2x",1)
	optbut.add_item("Pixelation 1x",2)
	optbut.add_item("'Full Scale'",3) 
 
	optbut.selected = 1

func _process(_delta):
	if get_tree().paused:
		self.visible = true
		gui_access.visible = true
		BG_gui_access_bdr.visible = true
	else:
		self.visible = false
		gui_access.visible = false
		BG_gui_access_bdr.visible = false

func unpause_demo() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false

func end_demo() -> void:
	get_tree().quit()

func set_scaling_mode(index : int) -> void:
	match index:
		0:
			optbut.selected = index
			control.scale_factor = 0.25 #Super Crunchy
			control.scale_change(0.25)
		1:
			optbut.selected = index
			control.scale_factor = 0.5 #Crunchy
			control.scale_change(0.50)
		2:
			optbut.selected = index
			control.scale_factor = 0.75 #A Little Crispy
			control.scale_change(0.75) 
		3:
			optbut.selected = index
			control.scale_factor = 1.0 #Full Sized
			control.scale_change(1.0) 

func set_fullscreen(button_pressed) -> void:
	if button_pressed: OS.set_window_fullscreen(true)
	if !button_pressed: OS.set_window_fullscreen(false)

func set_inverted_mouse(button_pressed) -> void:
	if button_pressed: 
		player.head.mouse_state = 1#INVERTED MOUSE
	if !button_pressed: 
		player.head.mouse_state = 0#REGULAR MOUSE
