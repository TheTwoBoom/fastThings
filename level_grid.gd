# level_grid.gd
extends GridContainer
@export_dir var levels_path: String = "res://levels"
@export var level_card_scene: PackedScene = load("res://ui/LevelCard.tscn")

var levels = [
	"res://levels/tutorial.tscn",
	"res://levels/level_1.tscn",
	"res://levels/level_2.tscn",
	"res://levels/level_3.tscn",
	"res://levels/level_4.tscn",
	"res://levels/level_5.tscn",
]

func _ready():
	for path in levels:
		var card = level_card_scene.instantiate()
		card.title = path.get_file().get_basename().capitalize()
		card.level_path = path
		card.earned_stars = int(load_stars(path.get_file().get_basename()))
		add_child(card)
		card.pressed_play.connect(_on_card_play)

func _on_card_play(scene_path: String):
	get_tree().change_scene_to_file(scene_path)
	
func load_stars(level_name: String) -> int:
	if not FileAccess.file_exists("user://savegame.save"):
		return 0

	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var data = {}
	if save_file != null:
		var json_str = save_file.get_as_text()
		if json_str.strip_edges() != "":
			var parsed = JSON.parse_string(json_str)
			if typeof(parsed) == TYPE_DICTIONARY:
				data = parsed
	save_file.close()

	return data.get(level_name, 0)
