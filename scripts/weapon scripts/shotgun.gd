extends Spatial
onready var player = get_tree().get_nodes_in_group("player")[0]
onready var wpnmngr = player.get_node("Head/Camera/WeaponManager")
onready var Statsdisplay = get_tree().get_nodes_in_group("statsdisplay")[0]
onready var anim_player = $AnimationPlayer
onready var bullet_emitters_base : Spatial = $BulletEmitter
onready var bullet_emitters = $BulletEmitter.get_children()
onready var shake = player.get_node("Head")
onready var shotgun = Statsdisplay.WEAPON_SLOTS.SHOTGUN
onready var shell_spawner = player.get_node("Head/Camera/ShellSpawn")

export var automatic = false
export var damage = 60
export var ammo = 18
export var attack_rate = 1.2

var shell = preload("res://scenes/SpentShellShotgun.tscn")

var fire_point : Spatial
var bodies_to_exclude: Array = []
var attack_timer : Timer
var can_attack = true
var shotgun_spread = 6

signal fired
signal out_of_ammo

func _ready():
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_rate
# warning-ignore:return_value_discarded
	attack_timer.connect("timeout", self, "finish_attack")
	attack_timer.one_shot = true
	add_child(attack_timer)

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
		ammo -= 2
		
	var shootsound = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Audio/ShotgfireFX")

	
	var start_transform = bullet_emitters_base.global_transform
	bullet_emitters_base.global_transform = fire_point.global_transform
	for bullet_emitter in bullet_emitters:
		bullet_emitter.fire()
	bullet_emitters_base.global_transform = start_transform

	if wpnmngr.cur_weapon == wpnmngr.weapons[shotgun]:
		shootsound.stop()
		shootsound.play()
		shake.shoot_animation(0.2)

	anim_player.stop()
	anim_player.play("attack")
	emit_signal("fired")
	can_attack = false
	attack_timer.start()
	spawn_shell()
	
	
func finish_attack():
	can_attack = true
	
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
	

func spawn_shell():
	var shell_instance1 = shell.instance()
	var shell_instance2 = shell.instance()
	
	get_tree().get_root().add_child(shell_instance1)
	shell_instance1.global_transform = shell_spawner.global_transform
	shell_instance1.linear_velocity = shell_spawner.global_transform.basis.x * 2.5
	get_tree().get_root().add_child(shell_instance2)
	shell_instance2.global_transform = shell_spawner.global_transform
	shell_instance2.linear_velocity = shell_spawner.global_transform.basis.x * 2.5
