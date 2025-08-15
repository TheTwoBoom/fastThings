extends Node3D
@onready var tutorial_label = %TutorialLabel
@onready var tutorial_button = %TutorialButton
@onready var arrow = %TutorialArrow
@onready var cam = %Camera3D
var stars_save = load("res://finish_pad.gd").new()
var menu_index = 0
var tutorial_text = [
	"This is your game charakter, I call him \"CharacterBody3D\"",
	"This is a null, this is the goal of the game. Reach this point",
	"A checkpoint. When you fall down, you respawn at your last checkpoint or the spawn",
	"Yeah, it moves. Self explaining?",
	"If you want those stars in the menu, you have to collect those Coins",
	"If you get on this thing you float, simple, isn't it?",
	"That are the basics, you will find out the other things later ☺️"
]


func _on_button_pressed() -> void:
	if menu_index == tutorial_text.size()-2:
		tutorial_button.text = "Back to Menu"
	elif menu_index == tutorial_text.size()-1:
		stars_save.save_star("tutorial", 3)
		get_tree().change_scene_to_file("res://levelselection.tscn")
		return
	menu_index += 1
	tutorial_label.text = tutorial_text[menu_index]
	match menu_index:
		1:
			arrow.global_position = Vector3(4.0, 4.0, 0.0)
		2:
			arrow.global_position = Vector3(4.0, 9.0, -4.0)
			cam.global_position = Vector3(4.0, 10.5, 3.0)
		3:
			arrow.global_position = Vector3(2.0, 7, -4.0)
		4:
			arrow.global_position = Vector3(0.0, 8.5, -4.0)
		5:
			arrow.global_position = Vector3(-4.0, 8.5, -4.0)
			cam.global_position = Vector3(-4.0, 7.5, 3)
