extends Area
onready var UseRay = get_parent().get_node("Head/Camera/Use")
var count = 0

func checkforboxes(body):
	if UseRay.object_grabbed and body.is_in_group("Throwable"):
		count += 1

	if count >= 1 and UseRay.object_grabbed: #2
		UseRay.dropheldobject()
		count = 0
#		pass
