extends Spatial
# This is the camera/view portion of the player script.
# It is a heavy modification of the Q_Move character controller
# originally created by Btan. The github link for the *original* 
# Q_Move source code can be found in the README.
# The original uses modified functions from Quake source code
# for weapon/head-bobbing.

onready var camera = $Camera
onready var player = get_parent()

enum {RMOUSE, IMOUSE}
var mouse_state = RMOUSE
var is_inverted = false

var bobtimes = [0,0,0]
var Q_bobtime : float = 0.0
var Q_bob : float = 0.0
var bobRight : float = 0.0
var bobForward : float = 0.0
var bobUp : float = 0.0
var idleRight : float = 0.0
var idleForward : float = 0.0
var idleUp : float =  0.0
var shakecam = false
var shaketime : float = 0.0
var shakelength = 0.0
var deltaTime : float = 0.0
var idletime : float = 0.0
var mouse_move : Vector2 = Vector2.ZERO
var mouse_rotation_x : float = 0.0
var newbob : bool = false
var oldy : float = 0.0
var v_dmg_time : float = 0.0
var v_dmg_roll : float = 0.0
var v_dmg_pitch : float = 0.0

#Bob
var cl_bob : float = 0.01             # default: 0.01
var cl_bobup : float = 0.5            # default: 0.5
var cl_bobcycle : float = 0.8         # default: 0.8
var ql_bob : float = 0.012            # default: 0.012
var ql_bobup : float = 0.5            # default: 0.5
var ql_bobcycle : float = 0.6         # default: 0.6

#Roll
var rollangles : float = 7.0          # default: 15.0 (WIDE movements)
var rollspeed : float = 300.0         # default: 300.0
var tiltextra : float = 2.0           # default: 2.0

#View Idle
var idlescale : float= 1.6            # default: 1.6
var iyaw_cycle : float = 1.5          # default: 1.5
var iroll_cycle : float = 1.0         # default: 1.0
var ipitch_cycle : float = 2.0        # default: 2.0
var iyaw_level : float = 0.1          # default: 0.1
var iroll_level : float = 0.2         # default: 0.2
var ipitch_level : float = 0.15       # default: 0.15
var mouse_sensitivity : float = 0.1 #FastMouse value 0.025
var ms_speed : float = 0.1
#FastMouse will be a func/toggle that will allow players with a high response mouse
#to change the mouse sensitivity float. FastMouse speeds are 1/4 speed of SlowMouse.

const kick_time : float = 0.5         # default: 0.5
const kick_amount : float = 0.6     # default: 0.6
var y_offset : float = 1.0              # default: 1.0 - also used 1.25

enum { VB_COS, VB_SIN, VB_COS2, VB_SIN2 }
const bob_mode = VB_SIN

var mouse := Vector2.ZERO

#--------#--------#--------#--------#
func _ready():
	newbob = false #if dont want it enabled, disable here, default is False.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	match mouse_state:
		RMOUSE:
			if event is InputEventMouseMotion:# and player.is_start == false:
				mouse_move = event.relative * ms_speed#0.1 #FastMouse value 0.0145
				mouse_rotation_x -= event.relative.y * mouse_sensitivity
				mouse_rotation_x = clamp(mouse_rotation_x, -90, 90)
				player.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		IMOUSE:
			#Inverted Mouse#
			if event is InputEventMouseMotion:
				mouse_move = event.relative * ms_speed#0.1 #FastMouse value 0.0145
				mouse_rotation_x += event.relative.y * mouse_sensitivity #this is the change
				mouse_rotation_x = clamp(mouse_rotation_x, -90, 90)
				player.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))


func _physics_process(delta):
	deltaTime = delta
	
	if player.is_dead:
		camera.rotation_degrees.z = 80
		transform.origin = Vector3(0, -1.6, 0)
		return
	
	# Set points of origin
	camera.rotation_degrees = Vector3(mouse_rotation_x, 0, 0)
	transform.origin = Vector3(0, y_offset, 0)
	
	velocity_roll()
	
	if player.velocity.length() <= 0.1:
		bobtimes = [0,0,0]
		Q_bobtime = 0.0
#		add_idle()
		view_idle()
	else:
		idletime = 0.0
		add_bob()
###
#	if newbob:
#		view_bob_modern()
#	else:
	view_bob_classic()
###
	smooth_step_up()
	
	if v_dmg_time > 0.0:
		camera.rotation_degrees.z += v_dmg_time / kick_time * v_dmg_roll
		camera.rotation_degrees.x += v_dmg_time / kick_time * v_dmg_pitch
		v_dmg_time -= delta
	
	if shakecam:
		shake(1)

func smooth_step_up():
	var current = player.global_transform.origin[1]
	if player.state != 1 and current - oldy > 0:
		oldy += deltaTime * 15.0
		if oldy > current:
			oldy = current
		if current - oldy > 1.2:
			oldy = current - 1.2
		transform.origin[1] += oldy - current
	else:
		oldy = current

func velocity_roll():
	var side : float
	
	side = calc_roll(player.velocity, rollangles, rollspeed) * 4
	camera.rotation_degrees.z += side

func calc_roll (velocity : Vector3, angle : float, speed : float):
	var s : float
	var side : float
	
	side = velocity.dot(-get_global_transform().basis.x)
	s = sign(side)
	side = abs(side)
	
	if (side < speed):
		side = side * angle / speed;
	else:
		side = angle;
	
	return side * s

func _unhandled_input(event: InputEvent): 
	if event is InputEventMouseMotion:
		mouse = event.relative

func add_idle():
	idletime += deltaTime
	idleRight = idlescale * sin(idletime * ipitch_cycle) * ipitch_level
	idleUp = idlescale * sin(idletime * iyaw_cycle) * iyaw_level
	idleForward = idlescale * sin(idletime * iroll_cycle) * iroll_level

func view_idle():
	camera.rotation_degrees.x += 0.0 #idleUp
	camera.rotation_degrees.y += 0.0 #idleRight
	camera.rotation_degrees.z += 0.0 #idleForward

func add_bob():
	bobRight = calc_bob(0.75, bob_mode, 0, bobRight)
	bobUp = calc_bob(1.50, bob_mode, 1, bobUp)
	bobForward = calc_bob(1.00, bob_mode, 2, bobForward)

func view_bob_modern():
	camera.rotation_degrees.z += bobRight * 0.8 
	camera.rotation_degrees.y -= bobUp * 0.8
	camera.rotation_degrees.x += bobRight * 0.8 #default 1.2 (better at 0.8)

func view_bob_classic():
	transform.origin[1] += calc_bob_classic()

func calc_bob_classic():
	var vel : Vector3
	var cycle : float
	
	if player.state != 0: 
		return Q_bob
	
	Q_bobtime += deltaTime
	cycle = Q_bobtime - int(Q_bobtime / ql_bobcycle) * ql_bobcycle
	cycle /= ql_bobcycle
	if cycle < ql_bobup:
		cycle = PI * cycle / ql_bobup
	else:
		cycle = PI + PI * (cycle - ql_bobup) / (1.0 - ql_bobup)
	
	vel = player.velocity
	Q_bob = sqrt(vel[0] * vel[0] + vel[2] * vel[2]) * ql_bob
	Q_bob = Q_bob * 0.3 + Q_bob * 0.7 * sin(cycle)
	Q_bob = clamp(Q_bob, -7.0, 4.0)
	
	return Q_bob

func calc_bob (freqmod : float, mode, bob_i : int, bob : float):
	var cycle : float
	var vel : Vector3
	
	if player.state != 0:
		return bob
	
	bobtimes[bob_i] += deltaTime * freqmod
	cycle = bobtimes[bob_i] - int( bobtimes[bob_i] / cl_bobcycle ) * cl_bobcycle
	cycle /= cl_bobcycle
	
	if cycle < cl_bobup:
		cycle = PI * cycle / cl_bobup
	else:
		cycle = PI + PI * ( cycle - cl_bobup)/( 1.0 - cl_bobup)
	
	vel = player.velocity
	bob = sqrt(vel[0] * vel[0] + vel[2] * vel[2]) * cl_bob
	
	if mode == VB_SIN:
		bob = bob * 0.3 + bob * 0.7 * sin(cycle)
	elif mode == VB_COS:
		bob = bob * 0.3 + bob * 0.7 * cos(cycle)
	elif mode == VB_SIN2:
		bob = bob * 0.3 + bob * 0.7 * sin(cycle) * sin(cycle)
	elif mode == VB_COS2:
		bob = bob * 0.3 + bob * 0.7 * cos(cycle) * cos(cycle)
	bob = clamp(bob, -7, 4)
	
	return bob

func trigger_shake(time : float):
	shakecam = true
	shaketime = 0.0
	shakelength = time
	yield(get_tree().create_timer(time),"timeout")
	shakecam = false

func shake(easing : int):
	var cycle = Vector3(33, 44, 36)
	var v_level = Vector3(-1.5, 2, 1.25)
	var s_scale : float
	
	shaketime += deltaTime 
	
# warning-ignore:narrowing_conversion
	easing = clamp(easing, 0, 2)
	if easing == 0: # No shake easing
		s_scale = 1.0
	elif easing == 1: # Ease off scaling towards the end of the shake
		var diff = shakelength - shaketime
		s_scale = diff if diff <= 1.0 else 1.0
	elif easing == 2: # Ease off scaling throughout the entire shake
		s_scale = 1.0 - shaketime/shakelength
	
	for i in range(3):
		camera.rotation_degrees[i] += s_scale * sin(shaketime * cycle[i]) * v_level[i]

#Trigger view kicks
func parse_damage(from : Vector3):
	var side : float
	
	side = from.dot(-get_global_transform().basis.z)
	v_dmg_roll = side * kick_amount
	side = from.dot(get_global_transform().basis.x)
	v_dmg_pitch = side * kick_amount
	v_dmg_time = kick_time
