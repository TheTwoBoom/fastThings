extends Area3D

func _on_body_entered(body) -> void:
	if (body.get_name() == "CharacterBody3D"):
		body.hoverpad = true

func _on_body_exited(body: Node3D) -> void:
	if (body.get_name() == "CharacterBody3D"):
		body.hoverpad = false
