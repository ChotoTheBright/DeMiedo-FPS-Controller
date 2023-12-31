extends Label

enum WEAPON_SLOTS {MACHETES, SHOTGUN, AUTOMATIC, ROCKET_L}

var slots_unlocked = {
	WEAPON_SLOTS.MACHETES: true,
	WEAPON_SLOTS.SHOTGUN: true,
	WEAPON_SLOTS.AUTOMATIC: true,
	WEAPON_SLOTS.ROCKET_L: true,
}

var cur_slot = 0
var last_slot = 0
var ammo = 0
var health = 0
var intruder = true #when you start, its just machetes. Named for Dusk's Intruder mode.

var p_health

func reset_weapons_to_start() -> void:
	slots_unlocked[WEAPON_SLOTS.SHOTGUN] = false
	slots_unlocked[WEAPON_SLOTS.AUTOMATIC] = false
	slots_unlocked[WEAPON_SLOTS.ROCKET_L] = false


func update_ammo(amnt):
	ammo = amnt
	update_display()

func update_health(amnt):
	health = amnt
	update_display()

func update_display():
	text = "Health:" + str(health) #"Health: "Corazón
	var ammo_amnt = str(ammo)
	if ammo < 0 :
		ammo_amnt = "-inf.-" #
	text += "Ammo:" + ammo_amnt # Munición
