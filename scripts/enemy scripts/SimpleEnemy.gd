extends KinematicBody

onready var player = get_tree().get_nodes_in_group("player")[0]
var navAgent : NavigationAgent
var velocity = Vector3()
var riding : bool
var _timer : Timer


func _ready():
	navAgent = $NavigationAgent
# warning-ignore:return_value_discarded
	navAgent.connect("velocity_computed", self, "_on_velocity_computed")
#	pass
	_timer = Timer.new()
	_timer.wait_time = 0.014
	# warning-ignore:return_value_discarded
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.one_shot = false
	add_child(_timer)
	_timer.start()
	#^ you can remove this timer start and add it elsewhere 
	# if you do not want the enemy to start right away.

func _physics_process(_delta):

	if navAgent.is_navigation_finished():
		return
	var targetPos = navAgent.get_next_location()
	var direction = global_transform.origin.direction_to(targetPos)
	navAgent.max_speed = navAgent.max_speed

	velocity = direction * navAgent.max_speed
	navAgent.set_velocity(velocity)
	

func _on_velocity_computed(_velocity):
# warning-ignore:return_value_discarded
	move_and_slide(_velocity, Vector3.UP)

func _on_Timer_timeout():
	navAgent.set_target_location(player.global_transform.origin)

