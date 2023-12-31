extends Spatial
onready var anim_player = $AnimationPlayer
onready var weapons = $Weapons.get_children()
onready var player = get_parent().get_parent().get_parent()
onready var wpnswap = player.get_node("Audio/WpnSwapFX")
onready var Statsdisplay = get_tree().get_nodes_in_group("statsdisplay")[0]
onready var _canattack = false

var cur_weapon = null
var ShootPoint : Spatial 
var bodies_to_exlude: Array = []

signal ammo_changed

func init(_fire_point: Spatial, _bodies_to_exclude: Array):
	ShootPoint = _fire_point
	bodies_to_exlude = _bodies_to_exclude
	for weapon in weapons:
		if weapon.has_method("init"):
			weapon.init(ShootPoint, _bodies_to_exclude)
	
	for weapon in weapons:
		weapon.connect("fired", self, "emit_ammo_changed_signal")

	#starting weapon goes here
	switch_to_weapon_slot(Statsdisplay.WEAPON_SLOTS.MACHETES)
#=============================================================================#

func attack(attack_input_just_pressed: bool, attack_input_held: bool):
	if _canattack == false:
		pass
	elif player.is_dead == true:
		pass
	else:
		if cur_weapon.has_method("attack"):
			cur_weapon.attack(attack_input_just_pressed, attack_input_held)

#THE WEAPONS CONNECT TO THIS WHEN AMMO RUNS OUT#
func switch_to_next_weapon(): 
	Statsdisplay.cur_slot = (Statsdisplay.cur_slot + 1) % Statsdisplay.slots_unlocked.size()
	if !Statsdisplay.slots_unlocked[Statsdisplay.cur_slot]:
		switch_to_next_weapon()
	else:
		switch_to_weapon_slot(Statsdisplay.cur_slot)

func switch_to_last_weapon():
	Statsdisplay.cur_slot = posmod((Statsdisplay.cur_slot - 1) , Statsdisplay.slots_unlocked.size())
	if !Statsdisplay.slots_unlocked[Statsdisplay.cur_slot]:
		switch_to_last_weapon()
	else:
		switch_to_weapon_slot(Statsdisplay.cur_slot)
#==========================================================
func switch_to_weapon_slot(slot_ind: int):
	if slot_ind < 0 or slot_ind >= Statsdisplay.slots_unlocked.size():
		return
	if !Statsdisplay.slots_unlocked[slot_ind]:
		return
	disable_all_weapons()
	cur_weapon = weapons[slot_ind]
	Statsdisplay.cur_slot = slot_ind
	if cur_weapon.has_method("set_active"):
		cur_weapon.set_active()
	else:
		cur_weapon.show()
	emit_ammo_changed_signal()

func disable_all_weapons():
	for weapon in weapons:
		if weapon.has_method("set_inactive"):
			weapon.set_inactive()
		else:
			pass

func update_animation(velocity: Vector3, grounded: bool):
	if cur_weapon.has_method("is_idle") and !cur_weapon.is_idle():
		anim_player.play("idle")
	if !grounded or velocity.length() < 15:
		anim_player.play("idle", 0.05)
	anim_player.play("idle")

func get_pickup(pickup_type, ammo):
	match pickup_type:
		Pickup.PICKUP_TYPES.SHOTGUN:
			if !Statsdisplay.slots_unlocked[Statsdisplay.WEAPON_SLOTS.SHOTGUN]:
				Statsdisplay.slots_unlocked[Statsdisplay.WEAPON_SLOTS.SHOTGUN] = true
				switch_to_weapon_slot(Statsdisplay.WEAPON_SLOTS.SHOTGUN)
			weapons[Statsdisplay.WEAPON_SLOTS.SHOTGUN].ammo += ammo
#-------------------------------------------------------------------------------------------#
		Pickup.PICKUP_TYPES.SHOTGUN_AMMO:
			weapons[Statsdisplay.WEAPON_SLOTS.SHOTGUN].ammo += ammo
#-------------------------------------------------------------------------------------------#
		Pickup.PICKUP_TYPES.AUTOMATIC:
			if !Statsdisplay.slots_unlocked[Statsdisplay.WEAPON_SLOTS.AUTOMATIC]:
				Statsdisplay.slots_unlocked[Statsdisplay.WEAPON_SLOTS.AUTOMATIC] = true
				switch_to_weapon_slot(Statsdisplay.WEAPON_SLOTS.AUTOMATIC)
			weapons[Statsdisplay.WEAPON_SLOTS.AUTOMATIC].ammo += ammo
#-------------------------------------------------------------------------------------------#
		Pickup.PICKUP_TYPES.AUTOMATIC_AMMO:
			weapons[Statsdisplay.WEAPON_SLOTS.AUTOMATIC].ammo += ammo
#-------------------------------------------------------------------------------------------#
		Pickup.PICKUP_TYPES.ROCKET_L:
			if !Statsdisplay.slots_unlocked[Statsdisplay.WEAPON_SLOTS.ROCKET_L]:
				Statsdisplay.slots_unlocked[Statsdisplay.WEAPON_SLOTS.ROCKET_L] = true
				switch_to_weapon_slot(Statsdisplay.WEAPON_SLOTS.ROCKET_L)
			weapons[Statsdisplay.WEAPON_SLOTS.ROCKET_L].ammo += ammo
#-------------------------------------------------------------------------------------------#
		Pickup.PICKUP_TYPES.ROCKET_L_AMMO:
			weapons[Statsdisplay.WEAPON_SLOTS.ROCKET_L].ammo += ammo
#-------------------------------------------------------------------------------------------#
	emit_ammo_changed_signal()

func emit_ammo_changed_signal():
	emit_signal("ammo_changed", cur_weapon.ammo)


