extends StaticBody3D

@export var move_distance: float = 5.0 # wie weit nach links/rechts
@export var speed: float = 2.0         # Bewegungsgeschwindigkeit

var start_pos: Vector3
var direction: int = 1

func _ready():
	start_pos = position

func _process(delta):
	position.x += direction * speed * delta
	
	# Prüfen ob Grenze erreicht
	if position.x > start_pos.x + move_distance:
		position.x = start_pos.x + move_distance
		direction = -1
	elif position.x < start_pos.x - move_distance:
		position.x = start_pos.x - move_distance
		direction = 1
