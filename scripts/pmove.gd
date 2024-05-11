class_name Player3D
extends KinematicBody
# This is the movement/actions portion of the player script.
# It is a heavy modification of the Q_Move character controller
# originally created by Btan2. The github link for the original 
# Q_Move source code link can be found in the README.

onready var collider : CollisionShape = $CollisionShape
onready var head : Spatial = $Head
onready var sfx : Node = $Audio
onready var _camera = $Head/Camera
onready var _wsight = $Head/Camera/WSight
#onready var thoughts = $ThoughtManager
onready var Statsdisplay = get_tree().get_nodes_in_group("statsdisplay")[0]
#-water-#
onready var waterfx = $Head/Camera/Underwater
onready var bloodpowerup = false
onready var in_blood = false

const MAXSPEED : float = 32.0         # default: 32.0 
const WALKSPEED : float = 20.0       # default: 16.0
const STOPSPEED : float = 10.0       # default: 10.0
const GRAVITY : float = 80.0         # default: 80.0 - const
const ACCELERATE : float = 10.0      # default: 10.0
const AIRACCELERATE : float = 0.25   # default: 0.7
const SWIMACCELERATE : float = 32.0   # default:  0.25
const MOVEFRICTION : float = 6.0     # default: 6.0
const JUMPFORCE : float = 27.0       # default: 27.0
const AIRCONTROL : float = 0.9       # default: 0.9
const SWIMCONTROL : float = 0.9       # default: 0.9
const STEPSIZE : float = 2.0         # default: 1.8
const MAXHANG : float = 0.2          # defualt: 0.2
const PLAYER_HEIGHT : float = 3.6    # default: 3.6
const CROUCH_HEIGHT : float = 2.0    # default: 2.0
const WATER_LAYER = 17

var water_normal : Vector3 = Vector3.UP
var deltaTime : float = 0.0
var movespeed : float = 32.0
var fmove : float = 0.0
var smove : float = 0.0
var ground_normal : Vector3 = Vector3.UP
var swim_normal : Vector3 = Vector3.FORWARD
var hangtime : float = 0.2
var impact_velocity : float = 0.0
var is_dead : bool = false
var is_start : bool = true
var jump_press : bool = false
var crouch_press : bool = false
var ground_plane : bool = false
var prev_y : float = 0.0
var velocity : Vector3 = Vector3.ZERO

var in_water = false
var _submerged : bool = false

enum {GROUNDED, FALLING, LADDER, SWIM}
var state = GROUNDED


func _input(_event):
	if is_dead: 	#Ignore inputs if dead
		fmove = 0.0
		smove = 0.0
		jump_press = false
		return
#	if is_start == true:
#		fmove = 0.0
#		smove = 0.0
#		jump_press = false
#		return
	
	fmove = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	smove = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	if Input.is_action_just_pressed("shift"):
		if movespeed == WALKSPEED:
			movespeed = MAXSPEED
		elif movespeed == MAXSPEED:
			movespeed = WALKSPEED
	
	if Input.is_action_just_pressed("jump") and !jump_press:
		jump_press = true
	elif Input.is_action_just_released("jump"):
		jump_press = false
	
	if state == GROUNDED and Input.is_action_just_pressed("crouch"):
		print("crouch SFX here")
#		sfx.play_crouch_sound()

	if Input.is_action_pressed("crouch"):
		crouch_press = true
	else:
		crouch_press = false

func _physics_process(delta):
	deltaTime = delta
	check_state()
	if in_water:
		state = SWIM
	else:
#		if is_start == false:
		crouch()
		categorize_position()
		jump_button()

func playercannowmove():
	#Sets the player in motion at the start of the game.
	$Head/Camera/WeaponManager._canattack = true

func check_state():
	match state:
		state.GROUNDED:
			ground_move()
		state.FALLING:
			air_move()
		state.SWIM:
			swim_move()

func crouch():
	if in_water:
		pass#return
	var crouch_speed = 20.0 * deltaTime
	
	if crouch_press: #snap crouch height while falling
		if state == FALLING:
			collider.shape.height = CROUCH_HEIGHT
		else:
			collider.shape.height -= crouch_speed 
	else:
		if collider.shape.height < PLAYER_HEIGHT:
			var up = transform.origin + Vector3.UP * crouch_speed
			var trace = Trace.new()
			trace.motion(transform.origin, up, collider.shape, self)
			if trace.fraction == 1:
				collider.shape.height += crouch_speed
	
	collider.shape.height = clamp(collider.shape.height, CROUCH_HEIGHT, PLAYER_HEIGHT)
	head.y_offset = collider.shape.height * 0.35

#Check if the player is touching the ground
func categorize_position():
	if in_water:
		return

	var down  : Vector3
	var trace : Trace
	
	# Check for ground 0.1 units below the player
	down = global_transform.origin + Vector3.DOWN * 0.1
	trace = Trace.new()
	trace.standard(global_transform.origin, down, collider.shape, self)
	
	ground_plane = false
	
	if trace.fraction == 1:
		state = FALLING
		ground_normal = Vector3.UP
	else: 
		ground_plane = true
		ground_normal = trace.normal
		
		if ground_normal[1] < 0.7:
			state = FALLING # Too steep!
		else:
			if state == FALLING:
				calc_fall()
			
			global_transform.origin = trace.endpos # Clamp to ground
			prev_y = global_transform.origin[1]
			impact_velocity = 0
			
			state = GROUNDED

func calc_fall():
	var fall_dist : int
	
	fall_dist = int(round(abs(prev_y - global_transform.origin[1])))

	if fall_dist > PLAYER_HEIGHT:
		pass
		#put landing SFX here
	if fall_dist >= 6: #6
		head.parse_damage(Vector3.ONE * float(impact_velocity / 8))

func jump_button():

	if is_dead: 
		return
	if in_water:
		return
	
	# Allow jump for a few frames if just ran off platform
	if state != FALLING:
		hangtime = MAXHANG
	else:
		hangtime -= deltaTime if hangtime > 0.0 else 0.0
	
	# Moving up too fast, don't jump
	if velocity[1] > 54.0: 
		return
	
	if hangtime > 0.0 and jump_press:
		state = FALLING
		jump_press = false
		hangtime = 0.0
		
		#put jump SFX here
		
		# Make sure jump velocity is positive if moving down
		if state == FALLING or velocity[1] < 0.0:
			velocity[1] = JUMPFORCE
			
		else:
			velocity[1] += JUMPFORCE

func ground_move():
	var wishdir : Vector3
	
	wishdir = (global_transform.basis.x * smove + -global_transform.basis.z * fmove).normalized()
	wishdir = wishdir.slide(ground_normal)
	
	ground_accelerate(wishdir, slope_speed(ground_normal[1]))
	#var original_velocity = velocity
	
	var ccd_max = 5
	for _i in range(ccd_max):
		var ccd_step = velocity / ccd_max
		var collision = move_and_collide(ccd_step * deltaTime)
		if collision:
			var normal = collision.get_normal()
			if normal[1] < 0.7 and !is_dead:
				var stepped = step_move(global_transform.origin, velocity.normalized() * 10)
				if !stepped and velocity.dot(normal) < 0:
					velocity = velocity.slide(normal)
			else:
				velocity = velocity.slide(normal)

func step_move(original_pos : Vector3, vel : Vector3):
	var dest  : Vector3
	var down  : Vector3
	var up    : Vector3
	var trace : Trace
	
	trace = Trace.new()
	
	# Get destination position that is one step-size above the intended move
	dest = original_pos
	dest[0] += vel[0] * deltaTime
	dest[1] += STEPSIZE
	dest[2] += vel[2] * deltaTime
	
	# 1st Trace: check for collisions one stepsize above the original position
	up = original_pos + Vector3.UP * STEPSIZE
	trace.standard(original_pos, up, collider.shape, self)
	
	dest[1] = trace.endpos[1]
	
	# 2nd Trace: Check for collisions one stepsize above the original position
	# and along the intended destination
	trace.standard(trace.endpos, dest, collider.shape, self)
	
	# 3rd Trace: Check for collisions below the stepsize until 
	# level with original position
	down = Vector3(trace.endpos[0], original_pos[1], trace.endpos[2])
	trace.standard(trace.endpos, down, collider.shape, self)
	
	# Move to trace collision position if step is higher than original position 
	# and not steep 
	if trace.endpos[1] > original_pos[1] and trace.normal[1] >= 0.7: 
		global_transform.origin = trace.endpos
		#velocity = velocity.slide(trace.normal)
		return true
	
	return false

#for ground move
func ground_accelerate(wishdir : Vector3, wishspeed : float):
	var friction : float
	
	friction = MOVEFRICTION
	
	# Friction applied after move release
	if wishdir != Vector3.ZERO:
		velocity = velocity.linear_interpolate(wishdir * wishspeed, ACCELERATE * deltaTime) 
	else:
		velocity = velocity.linear_interpolate(Vector3.ZERO, friction * deltaTime) 

#Change velocity while moving up/down sloped ground
func slope_speed(y_normal : float):
	if y_normal <= 0.97:
		var multiplier = y_normal if velocity[1] > 0.0 else 2.0 - y_normal
		return clamp(movespeed * multiplier, 5.0, movespeed * 1.2)
	return movespeed

func air_move():
	var wishdir : Vector3
	
	wishdir = (global_transform.basis.x * smove + -global_transform.basis.z * fmove).normalized()
	wishdir = wishdir.slide(ground_normal)
	#wishdir[1] = 0.0
	
	air_accelerate(wishdir, STOPSPEED if velocity.dot(wishdir) < 0 else AIRACCELERATE)
	
	if !ground_plane:
		if (AIRCONTROL > 0.0): 
			air_control(wishdir)
	
	velocity[1] -= GRAVITY * deltaTime
	
	# Cache Y position if moving/jumping up
	if global_transform.origin[1] >= prev_y: 
		prev_y = global_transform.origin[1]
	
	impact_velocity = abs(int(round(velocity[1])))
	
	var ccd_max = 5
	for _i in range(ccd_max):
		var ccd_step = velocity / ccd_max
		var collision = move_and_collide(ccd_step * deltaTime)
		if collision:
			var normal = collision.get_normal()
			if velocity.dot(normal) < 0:
				velocity = velocity.slide(normal)
				

func air_accelerate(wishdir : Vector3, accel : float):
	var addspeed     : float
	var accelspeed   : float
	var currentspeed : float
	
	var wishspeed = slope_speed(ground_normal[1])
	
	currentspeed = velocity.dot(wishdir)
	addspeed = wishspeed - currentspeed
	if addspeed <= 0.0: 
		return
	
	accelspeed = accel * deltaTime * wishspeed
	if accelspeed > addspeed: accelspeed = addspeed
	
	velocity[0] += accelspeed * wishdir[0]
	velocity[1] += accelspeed * wishdir[1]
	velocity[2] += accelspeed * wishdir[2]

func air_control(wishdir : Vector3):
	var dot        : float
	var speed      : float
	var original_y : float
	
	if fmove == 0.0: 
		return
	
	original_y = velocity[1]
	velocity[1] = 0.0
	speed = velocity.length()
	velocity = velocity.normalized()
	
	# Change direction while slowing down
	dot = velocity.dot(wishdir)
	if dot > 0.0 :
		var k = 32.0 * AIRCONTROL * dot * dot * deltaTime
		velocity[0] = velocity[0] * speed + wishdir[0] * k
		velocity[1] = velocity[1] * speed + wishdir[1] * k
		velocity[2] = velocity[2] * speed + wishdir[2] * k
		velocity = velocity.normalized()
	
	velocity[0] *= speed
	velocity[1] = original_y
	velocity[2] *= speed

func swim_move():
	var wishdir : Vector3

	wishdir = (global_transform.basis.x * smove + -global_transform.basis.z * fmove).normalized()
	wishdir = wishdir.slide(water_normal)

	swim_accelerate(wishdir, STOPSPEED if velocity.dot(wishdir) < 0 else SWIMACCELERATE)
	swim_control(wishdir) 

	if Input.is_action_pressed("jump"):
		velocity[1] = 8.0
	else: #CHANGE DONE HERE#
		velocity[1] -= 4.0

	if _wsight.is_colliding():
		if _wsight.get_collider().is_in_group("boots") and Input.is_action_pressed("move_forward"):
			velocity[1] = 6.0 * -1

	var ccd_max = 5
	for _i in range(ccd_max):
		var ccd_step = velocity / ccd_max
		var collision = move_and_collide(ccd_step * 0.0177) #deltaTime is 0.016667
		if collision:
			var normal = collision.get_normal()
			if velocity.dot(normal) < 0:
				velocity = velocity.slide(normal)

func swim_accelerate(wishdir : Vector3, accel : float):
	var addspeed     : float
	var accelspeed   : float
	var currentspeed : float

	var wishspeed = slope_speed(swim_normal[1])

	currentspeed = velocity.dot(wishdir)
	addspeed = wishspeed - currentspeed
	if addspeed <= 0.0: 
		return

	accelspeed = accel * deltaTime * wishspeed
	if accelspeed > addspeed: accelspeed = addspeed

	velocity[0] = accelspeed * wishdir[0]
	velocity[1] = accelspeed * wishdir[1]
	velocity[2] = accelspeed * wishdir[2]

func swim_control(_wishdir : Vector3):
	var speed      : float
	var original_y : float

	if fmove == 0.0: 
		return

	original_y = velocity[1]
	velocity[1] = 0.0
	speed = velocity.length()
	velocity = velocity.normalized()

	velocity[0] *= speed
	velocity[1] = -original_y
	velocity[2] *= speed

func swim_powerup():
	bloodpowerup = true

#Push can be used for rocket jumps, impact damage etc.
func push(force : float, dir : Vector3, mass : float):
	for i in range(3):
		velocity[i] += force * dir[i] / mass
