extends KinematicBody

export var start_move_speed = 30
export var grav = 30.0#5.0
export var drag = 0.01
export var velo_retained_on_bounce = 0.8
var velocity = Vector3.ZERO
var initialized = false
var coltimer : Timer


func init():
	initialized = true
	velocity = -global_transform.basis.y * start_move_speed

	
func _physics_process(delta):
	if !initialized:
		return
	velocity += -velocity * drag + Vector3.DOWN * grav * delta
	var collision = move_and_collide(velocity * delta)
	if collision:
		var d = velocity
		var n = collision.normal
		var r = d - 2 * d.dot(n) * n
		velocity = r * velo_retained_on_bounce


func remove_hitbox():
	velocity = Vector3.ZERO
	velo_retained_on_bounce = 0.0
	grav = 0.0
	$CollisionShape.disabled = true# queue_free()
	queue_free() #can remove this or comment out to only have gibs hitbox removed, leaving them in the level.
	
