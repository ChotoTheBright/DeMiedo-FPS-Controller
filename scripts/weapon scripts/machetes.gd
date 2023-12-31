extends Spatial

onready var player = get_tree().get_nodes_in_group("player")[0]
onready var wpnmngr = player.get_node("Head/Camera/WeaponManager")
onready var Statsdisplay = get_tree().get_nodes_in_group("statsdisplay")[0]
onready var anim_player = $AnimationPlayer
onready var bullet_emitters_base : Spatial = $BulletEmitter
onready var bullet_emitters = $BulletEmitter.get_children()
onready var shake = player.get_node("Head")
onready var machetes = Statsdisplay.WEAPON_SLOTS.MACHETES
onready var _damagearea = $BulletEmitter/DamageArea 

export var automatic = true
export var damage = 25
export var ammo = -1
export var attack_rate = 0.5

var ShootPoint : Spatial
var bodies_to_exclude: Array = []
var attack_timer : Timer
var can_attack = true
var strike_range = false

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
	ShootPoint = _fire_point
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
		if attack_input_just_pressed:
			emit_signal("out_of_ammo")
		return
		
	if ammo > 0:
		pass
		

	var shootsound = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Audio/MacheteFX")
#	var shootsoundimpact = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("Audio/MacheteHitFX")

	var start_transform = bullet_emitters_base.global_transform
	bullet_emitters_base.global_transform = ShootPoint.global_transform
	for bullet_emitter in bullet_emitters:
		bullet_emitter.fire()
	bullet_emitters_base.global_transform = start_transform

	anim_player.play("attack", 0.2)
	
	emit_signal("fired")
	can_attack = false
	attack_timer.start()

	if strike_range == true:
		#add impact FX here
		return

	shootsound.play()
	
	
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
	

func _on_enemy_entered(body):
	if body.is_in_group("enemy"):
		strike_range = true
	else:
		pass


func _on_enemy_exited(body):
	if body.is_in_group("enemy"):
		strike_range = false
	else:
		pass


func _on_enemy_area_entered(area):
	if area.is_in_group("enemy"):
		strike_range = true
	else:
		pass


func _on_enemy_area_exited(area):
	if area.is_in_group("enemy"):
		strike_range = false
	else:
		pass
