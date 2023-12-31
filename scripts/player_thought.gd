extends Area
class_name PlayerThought
signal thought_sound
#signal DeleteFromOtherNode // #		emit_signal("DeleteFromOtherNode")

enum THOUGHT_NUM {t1, t2, t3, t4, t5, t6}

export(THOUGHT_NUM) var thought_number

onready var delete_timer = $Timer

func _on_body_entered(body):
	if body.is_in_group("player"):
		delete_timer.start()
		$CollisionShape.disabled = true
		emit_signal("thought_sound")

func _on_Timer_timeout():
	queue_free()

func _on_body_exited(body):
	if body.is_in_group("player"):
		delete_timer.start()
		emit_signal("thought_sound")

func standalone_call():
	delete_timer.start()
	$CollisionShape.disabled = true
	emit_signal("thought_sound")
