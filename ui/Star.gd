extends Control
@export var outline_width: float = 4.0
@export var inner_ratio: float = 0.45
@export var filled: bool = false
@export var outline_color: Color = Color.hex(0x3a2a23ff)  # dunkles Braun
@export var fill_color: Color = Color.hex(0xffd700ff)

func _notification(what):
	if what == NOTIFICATION_THEME_CHANGED or what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw():
	var cx := size.x * 0.5
	var cy := size.y * 0.5
	var R = min(size.x, size.y) * 0.48
	var r = R * inner_ratio
	var pts: PackedVector2Array = []
	for i in range(10):
		var ang := -PI/2.0 + float(i) * PI/5.0
		var rad = R if i % 2 == 0 else r
		pts.append(Vector2(cx + cos(ang) * rad, cy + sin(ang) * rad))
	if filled:
		print("fill!")
		draw_colored_polygon(pts, fill_color)
	# geschlossene Outline
	var closed := pts.duplicate()
	closed.append(pts[0])
	draw_polyline(closed, outline_color, outline_width, true)
