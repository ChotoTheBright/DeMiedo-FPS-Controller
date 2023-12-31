extends RayCast
signal canusethis

onready var usetimer = $UseTimer
onready var usetext = $UseText
onready var usetween = $UseTween
onready var statsdisplay = get_tree().get_nodes_in_group("statsdisplay")[0]
onready var weapons = get_parent().get_node("WeaponManager")

var firetimer : Timer
var mass_limit = 150
var throw_force = 50
var object_grabbed = null
var Target = null
var can_use = true
var text_visible = false
var _text = "Use"

func _ready():
	usetext.modulate = Color(0.98, 0.71, 0.08, 0)
	firetimer = Timer.new()
	firetimer.wait_time = 0.25
# warning-ignore:return_value_discarded
	firetimer.connect("timeout", self, "canfireagain")
	firetimer.one_shot = true
	add_child(firetimer)

func _physics_process(_delta):
	Target = get_collider();
	if get_collider() and usetimer.is_stopped() and Target.is_in_group("Useable"):
		pass#prompt("Use")
	elif not object_grabbed and usetimer.is_stopped() and get_collider() is RigidBody and get_collider().mass <= mass_limit:
		pass#prompt("Grab")
	else:
		unprompt()
		
	# Drop object if it goes too far
	if object_grabbed:
		var vector = $UseRange.global_transform.origin - object_grabbed.global_transform.origin
		object_grabbed.linear_velocity = vector * 10
		object_grabbed.axis_lock_angular_x = true
		object_grabbed.axis_lock_angular_y = true
		object_grabbed.axis_lock_angular_z = true

		if vector.length() >= 4: #3
			object_grabbed.set_mode(0)
			release()

	# On key press
	if Input.is_key_pressed(KEY_E):
		if can_use:
			can_use = false
			if get_collider() and usetimer.is_stopped() and Target.is_in_group("Useable"):
				Target._Interact()
				usetimer.start()
			elif not object_grabbed:
				if get_collider() is RigidBody and usetimer.is_stopped() and Target.mass <= mass_limit:
					object_grabbed = Target
					object_grabbed.rotation_degrees.x = 0
					object_grabbed.rotation_degrees.z = 0
			else:
				release()
	else:
		can_use = true
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			if object_grabbed:
				if object_grabbed.has_method("thrown"):
					object_grabbed.thrown()
				object_grabbed.linear_velocity = global_transform.basis.z * -throw_force
				release()
#			if object_grabbed:
#				object_grabbed.linear_velocity = global_transform.basis.z * -throw_force
#				release()
		
func release():
	object_grabbed.axis_lock_angular_x = false
	object_grabbed.axis_lock_angular_y = false
	object_grabbed.axis_lock_angular_z = false
	object_grabbed = null
	usetimer.start()
	firetimer.start()
		
func prompt(text):
	emit_signal("canusethis", _text) #
	if not text_visible:
		usetext.text = text
		text_visible = true
		var animation_speed = 0.25
		usetween.interpolate_property(usetext, "margin_top", 90, 80, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		usetween.interpolate_property(usetext, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		usetween.start()

func unprompt():
	if text_visible:
		text_visible = false
		var animation_speed = 0.25
		usetween.interpolate_property(usetext, "margin_top", 80, 90, animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		usetween.interpolate_property(usetext, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), animation_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		usetween.start()
		usetimer.start()

func canfireagain():
	weapons.switch_to_weapon_slot(statsdisplay.cur_slot)
	weapons._canattack = true

func dropheldobject():
	if object_grabbed:
		release()
