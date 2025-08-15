extends Area3D

func _on_body_entered(body) -> void:
	if (body.get_name() == "CharacterBody3D"):
		var star2 = get_node("/root/Node3D/CanvasLayer/ControlFinish/CenterContainer/AspectRatioContainer/VBoxContainer/HBoxContainer/Star2")
		var star3 = get_node("/root/Node3D/CanvasLayer/ControlFinish/CenterContainer/AspectRatioContainer/VBoxContainer/HBoxContainer/Star3")
		body.move_lock = true
		var scene_name = get_tree().current_scene.scene_file_path.get_file().get_basename()
		if body.coins < 4:
			save_star(scene_name, 1)
			star2.visible = false
			star3.visible = false
		elif body.coins < 6:
			save_star(scene_name, 2)
			star3.visible = false
		else:
			save_star(scene_name, 3)
		body.finish_popup.visible = true

func save_star(level_name: String, stars: int) -> void:
	var data = {}
	if FileAccess.file_exists("user://savegame.save"):
		var read_file = FileAccess.open("user://savegame.save", FileAccess.READ)
		var json_str = read_file.get_as_text()
		read_file.close()
		if json_str.strip_edges() != "":
			var parsed = JSON.parse_string(json_str)
			if typeof(parsed) == TYPE_DICTIONARY:
				data = parsed

	# Nur speichern, wenn der neue Wert höher ist
	if stars > data.get(level_name, 0):
		data[level_name] = stars

	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	save_file.store_string(JSON.stringify(data))
	save_file.close()
