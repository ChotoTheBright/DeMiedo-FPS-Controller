extends Area

signal is_thinking

func _on_area_entered(thought: PlayerThought):
	if thought.is_in_group("thoughtbubble"):
		emit_signal("is_thinking", thought.thought_number)

func thought_activated(thought: PlayerThought):
	emit_signal("is_thinking", thought.thought_number)
