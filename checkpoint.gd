extends Area3D

func _on_body_entered(body) -> void:
	if (body.get_name() == "CharacterBody3D"):
		queue_free()
		body.set_checkpoint()
