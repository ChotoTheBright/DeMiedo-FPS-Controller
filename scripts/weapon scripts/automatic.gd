extends Spatial

onready var player = get_tree().get_nodes_in_group("player")[0]
onready var wpnmngr = player.get_node("Head/Camera/WeaponManager")
onready var Statsdisplay = get_tree().get_nodes_in_group("statsdisplay")[0]#statsdisplay
onready var anim_player = $AnimationPlayer
onready var bullet_emitters_base : Spatial = $BulletEmitter
onready var bullet_emitters = $BulletEmitter.get_children()
onready var head = player.get_node("Head")
onready var automatico = Statsdisplay.WEAPON_SLOTS.AUTOMATIC
onready var shell_spawner = player.get_node("Head/Camera/ShellSpawn")
onready var bulletspread = player.get_node("Head/Camera/BulletSpread") 
onready var graphics = $Graphics

export var automatic = true
export var damage = 35
export var ammo = 0
export var attack_rate = 0.13

var shell = preload("res://scenes/SpentShell.tscn")
var fire_point : Spatial
var bodies_to_exclude: Array = []
var attack_timer : Timer
var can_attack = true
var spread = 6
var shakegun = false
var shaketime : float = 0.0
var shakelength = 0.0
var deltaTime : float = 0.0
var idletime : float = 0.0
var start_transform

signal fired
signal out_of_ammo

func _ready():
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_rate
# warning-ignore:return_value_discarded
	attack_timer.connect("timeout", self, "finish_attack")
	attack_timer.one_shot = true
	add_child(attack_timer)
	shakelength = 0.2

func _physics_process(delta):
	deltaTime = delta

func init(_fire_point: Spatial, _bodies_to_exclude: Array):
	fire_point = _fire_point
	bodies_to_exclude = _bodies_to_exclude
	for bullet_emitter in bullet_emitters:
		bullet_emitter.set_damage(damage)
		bullet_emitter.set_bodies_to_exclude(bodies_to_exclude)

func attack(attack_input_just_pressed: bool, attack_input_held: bool):
	if !can_attack:
		return
	if automatic and !attack_input_held:
		return
	elif !automatic and !attack_input_just_pressed:
		return
		
	if ammo == 0:
		emit_signal("out_of_ammo")
		return
	if ammo > 0:
		ammo -= 1
	var shootsound = player.get_node("Audio/AutofireFX")

	start_transform = bullet_emitters_base.global_transform
	bullet_emitters_base.global_transform = fire_point.global_transform
	for bullet_emitter in bullet_emitters:
		bullet_emitter.fire()
	bullet_emitters_base.global_transform = start_transform

	shootsound.play()
	head.trigger_shake(shakelength)#0.2
	shoot_animation()
	gun_movement()

	anim_player.play("attack")
	emit_signal("fired")
	can_attack = false
	attack_timer.start()
	spawn_shell()
	
func finish_attack():
	can_attack = true
	anim_player.play("idle")
	
func set_active():
	#put swap FX here
	show()
	can_attack = true
	
func set_inactive():
	can_attack = false
	anim_player.play("idle")
	hide()

func is_idle():
	return !anim_player.is_playing() or anim_player.current_animation == "idle"
	

func shoot_animation():
	randomize()
	var value = rand_range(0.8, 1)

	value = rand_range(1, 3)
	bulletspread.interpolate_property(fire_point, "translation:z", 0, value, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	bulletspread.interpolate_property(fire_point, "translation:z", value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)

	value = rand_range(-1.0, 1.0) #-0.005, 0.005
	bulletspread.interpolate_property(fire_point, "translation:x", 0, value, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	bulletspread.interpolate_property(fire_point, "translation:x",value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)

	value = rand_range(-.8, .8) #0.005, 0.015 graphics
	bulletspread.interpolate_property(fire_point, "translation:y", 0, value, 0.075, Tween.TRANS_SINE, Tween.EASE_OUT)
	bulletspread.interpolate_property(fire_point, "translation:y", value, 0, 0.12, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.075)

	value = rand_range(-1.5, -0.5)
	bulletspread.interpolate_property(fire_point, "rotation_degrees:x", 0, value, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	bulletspread.interpolate_property(fire_point, "rotation_degrees:x", value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)

	value = rand_range(-1, 1)
	bulletspread.interpolate_property(fire_point, "rotation_degrees:z", 0, value, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
	bulletspread.interpolate_property(fire_point, "rotation_degrees:z", value, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.05)
	bulletspread.interpolate_property(fire_point, "rotation_degrees:z", 0, -value, 0.075, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	bulletspread.interpolate_property(fire_point, "rotation_degrees:z", -value, 0, 0.075, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.175)

	value = rand_range(-1, -5)
	bulletspread.interpolate_property(fire_point, "rotation_degrees:z", 0, value, 0.05, Tween.TRANS_SINE, Tween.EASE_OUT)
	bulletspread.interpolate_property(fire_point, "rotation_degrees:z", value, 0, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.05)
	bulletspread.start()

func gun_movement():
	randomize()
	var value = rand_range(0.8, 1)

	value = rand_range(0.035, 0.045 ) 
	bulletspread.interpolate_property(graphics, "translation:z", 0, value, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	bulletspread.interpolate_property(graphics, "translation:z", value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)

	value = rand_range(-0.02, 0.02) #
	bulletspread.interpolate_property(graphics, "translation:x", 0, value, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	bulletspread.interpolate_property(graphics, "translation:x",value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)


	value = rand_range(0.005, 0.015) # graphics
	bulletspread.interpolate_property(graphics, "translation:y", 0, value, 0.075, Tween.TRANS_SINE, Tween.EASE_OUT)
	bulletspread.interpolate_property(graphics, "translation:y", value, 0, 0.12, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.075)


	value = rand_range(-1.5, -0.5)
	bulletspread.interpolate_property(graphics, "rotation_degrees:x", 0, value, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	bulletspread.interpolate_property(graphics, "rotation_degrees:x", value, 0, 0.15, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)

	bulletspread.start()


func spawn_shell():
	var shell_instance = shell.instance()
	get_tree().get_root().add_child(shell_instance)
	shell_instance.global_transform = shell_spawner.global_transform
	shell_instance.linear_velocity = shell_spawner.global_transform.basis.x * 2.5
