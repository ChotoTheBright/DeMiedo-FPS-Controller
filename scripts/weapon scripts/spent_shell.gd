extends RigidBody

func _ready():
	pass # Replace with function body.


func _on_Lifetime_timeout():
	queue_free()
