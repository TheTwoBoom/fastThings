extends Control

# --- Editor-Properties ---
@export_file("*.tscn") var level_path: String
@export var preview_size: Vector2i = Vector2i(320, 220)
@export var title: String = "LEVEL 1" : set = _set_title
@export var max_stars: int = 3 : set = _set_max_stars
@export var earned_stars: int = 0 : set = _set_earned_stars

# Farben (an dein Bild angelehnt)
var COL_BROWN_BG    = Color.hex(0x4d372cff)
var COL_BROWN_FRAME = Color.hex(0x3a2a23ff)
var COL_CARD_BG     = Color.hex(0x6b4b3aff)
var COL_HEADER_BG   = Color.hex(0xe9d9b6ff)
var COL_PREVIEW_BG  = Color.hex(0x8fd0e1ff)
var COL_PLAY_BG     = Color.hex(0xe9d9b6ff)

signal pressed_play(scene_path: String)

@onready var card: Panel                      = $Card
@onready var header: Panel                    = $Card/Margin/VBox/Header
@onready var title_label: Label               = $Card/Margin/VBox/Header/Title
@onready var pv_container: SubViewportContainer = $Card/Margin/VBox/PreviewWrap/PvContainer
@onready var pv: SubViewport                  = $Card/Margin/VBox/PreviewWrap/PvContainer/Pv
@onready var stars_box: HBoxContainer         = $Card/Margin/VBox/PreviewWrap/Stars
@onready var play_btn: Button                 = $Card/Margin/VBox/PlayWrap/Play

func _ready():
	_apply_theme()
	title_label.text = title
	_setup_stars()
	_setup_play_button()
	_ensure_preview_size()
	if level_path != "":
		_load_preview(level_path)

func _apply_theme():
	# Hintergrundfarbe (optional für die Scene selbst)
	modulate = Color.WHITE

	# Karte
	var sb_card := StyleBoxFlat.new()
	sb_card.bg_color = COL_CARD_BG
	sb_card.border_color = COL_BROWN_FRAME
	sb_card.border_width_top = 10
	sb_card.border_width_bottom = 10
	sb_card.border_width_left = 10
	sb_card.border_width_right = 10
	sb_card.corner_radius_top_left = 28
	sb_card.corner_radius_top_right = 28
	sb_card.corner_radius_bottom_left = 28
	sb_card.corner_radius_bottom_right = 28
	card.add_theme_stylebox_override("panel", sb_card)

	# Header
	var sb_head := StyleBoxFlat.new()
	sb_head.bg_color = COL_HEADER_BG
	sb_head.border_color = COL_BROWN_FRAME
	sb_head.border_width_top = 8
	sb_head.border_width_bottom = 8
	sb_head.border_width_left = 8
	sb_head.border_width_right = 8
	sb_head.corner_radius_top_left = 18
	sb_head.corner_radius_top_right = 18
	sb_head.corner_radius_bottom_left = 18
	sb_head.corner_radius_bottom_right = 18
	header.add_theme_stylebox_override("panel", sb_head)

	# Label
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", COL_BROWN_FRAME)

	# Play-Button (3 States)
	var make_circle := func(bg: Color) -> StyleBoxFlat:
		var sb := StyleBoxFlat.new()
		sb.bg_color = bg
		sb.border_color = COL_BROWN_FRAME
		sb.border_width_top = 10
		sb.border_width_bottom = 10
		sb.border_width_left = 10
		sb.border_width_right = 10
		sb.corner_radius_top_left = 999
		sb.corner_radius_top_right = 999
		sb.corner_radius_bottom_left = 999
		sb.corner_radius_bottom_right = 999
		return sb
	play_btn.add_theme_stylebox_override("normal",  make_circle.call(COL_PLAY_BG))
	play_btn.add_theme_stylebox_override("hover",   make_circle.call(COL_PLAY_BG.lightened(0.05)))
	play_btn.add_theme_stylebox_override("pressed", make_circle.call(COL_PLAY_BG.darkened(0.05)))
	play_btn.add_theme_font_size_override("font_size", 36)
	play_btn.add_theme_color_override("font_color", COL_BROWN_FRAME)

func _setup_play_button():
	play_btn.text = ""
	play_btn.custom_minimum_size = Vector2(88, 88)
	play_btn.pressed.connect(func():
		emit_signal("pressed_play", level_path)
	)

func _setup_stars():
	# Sicherstellen, dass genau max_stars Sterne vorhanden sind
	while stars_box.get_child_count() < max_stars:
		var star := preload("res://ui/Star.gd").new()
		star.custom_minimum_size = Vector2(40, 40)
		stars_box.add_child(star)
	while stars_box.get_child_count() > max_stars:
		stars_box.get_child(stars_box.get_child_count() - 1).queue_free()
	_apply_star_fill()

func set_earned_stars(v: int) -> void:
	earned_stars = clamp(v, 0, max_stars)
	_apply_star_fill()

func _apply_star_fill():
	for i in range(stars_box.get_child_count()):
		stars_box.get_child(i).filled = (i < earned_stars)
		stars_box.get_child(i).queue_redraw()

func _ensure_preview_size():
	pv.size = preview_size
	pv_container.stretch = true

func _load_preview(scene_path: String):
	
	var world := World3D.new()
	pv.world_3d = world
	
	# Vorherige Inhalte leeren
	for c in pv.get_children():
		c.queue_free()

	# Scene instanzieren
	var ps = load(scene_path)
	if ps == null:
		return
	var inst = ps.instantiate()
	pv.add_child(inst)

	# 2D oder 3D erkennen und Kamera setzen
	if inst is Node2D:
		_setup_camera_2d(inst)
	elif inst is Node3D:
		_setup_camera_3d(inst)
	else:
		# Fallback: einfacher farbiger Hintergrund
		var bg := ColorRect.new()
		bg.color = COL_PREVIEW_BG
		pv.add_child(bg)

	# Performance: nur updaten wenn sichtbar (oder: einmalig rendern → auskommentieren)
	pv.render_target_update_mode = SubViewport.UPDATE_ONCE

	# --- OPTIONAL: einmaliges Standbild statt Live ---
	# await get_tree().process_frame
	# var img := pv.get_texture().get_image()
	# var tex := ImageTexture.create_from_image(img)
	# var texrect := TextureRect.new()
	# texrect.texture = tex
	# texrect.stretch_mode = TextureRect.STRETCH_SCALE
	# pv_container.replace_by(texrect)
	# pv.queue_free()

func _setup_camera_2d(root2d: Node2D):
	var cam := Camera2D.new()
	cam.current = true
	cam.zoom = Vector2(1.0, 1.0)
	cam.position = Vector2.ZERO
	pv.add_child(cam)

	# Hintergrund „Himmelblau“, falls Scene keinen eigenen BG hat:
	var sky := ColorRect.new()
	sky.color = COL_PREVIEW_BG
	sky.size = preview_size
	pv.add_child(sky)
	sky.move_to_front() # unter Kamera egal; 2D stack: später vorne -> wir wollen BG hinten
	sky.z_index = -1000

func _setup_camera_3d(root3d: Node3D):
	for node in root3d.get_children():
		if node is CanvasLayer:
			node.visible = false
	var cam := Camera3D.new()
	pv.add_child(cam)
	cam.transform.origin = Vector3(5, 7, 5)
	cam.look_at(Vector3(0, 1, 0), Vector3.UP)
	cam.current = true
	cam.set_orthogonal(13, 0.05, 4000)
	cam.rotation_degrees = Vector3(-30, 45, 0)

	var light := DirectionalLight3D.new()
	pv.add_child(light)
	light.rotation_degrees.x = -45

func _set_title(value: String) -> void:
	title = value
	if Engine.is_editor_hint():
		title_label.text = title
		_setup_stars()
		_ensure_preview_size()

func _set_max_stars(value: int) -> void:
	max_stars = value
	if Engine.is_editor_hint():
		_setup_stars()
		_ensure_preview_size()

func _set_earned_stars(value: int) -> void:
	earned_stars = clamp(value, 0, max_stars)
	if Engine.is_editor_hint():
		_apply_star_fill()
