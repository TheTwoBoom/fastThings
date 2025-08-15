extends Control
var settings_script = load("res://settings.gd").new()

func _ready() -> void:
	settings_script.load_settings()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://levelselection.tscn")


func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://settings.tscn")


func _on_exit_button_pressed():
	get_tree().quit()


func _on_credits_button_pressed():
	get_tree().change_scene_to_file("res://credits.tscn")


func _on_return_button_pressed():
	get_tree().change_scene_to_file("res://title_screen.tscn")
