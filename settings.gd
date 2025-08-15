extends Node

# Settings-Daten
var max_fps: int = 60
var graphics_quality: int = 1 # 0=Low, 1=Medium, 2=High
var resolution_scale: float = 1.0
var msaa_level: int = 2 # 0=Aus, 2=2x, 4=4x
var shadow_quality: int = 2
var texture_lod_bias: float = 0.0
var fov: float = 75.0
var mouse_sensitivity: float = 1.0
var master_volume: float = 1.0

func apply_settings():
	# FPS
	if max_fps > 0:
		Engine.max_fps = max_fps
	else:
		Engine.max_fps = 0
	print(graphics_quality)
	print(max_fps)
	# Automatische Grafik-Settings basierend auf graphics_quality
	match graphics_quality:
		0: # Low
			resolution_scale = 0.7
			msaa_level = Viewport.MSAA_DISABLED
			shadow_quality = 1
		1: # Medium
			resolution_scale = 0.85
			msaa_level = Viewport.MSAA_2X
			shadow_quality = 1.5
		2: # High
			resolution_scale = 1.0
			msaa_level = Viewport.MSAA_4X
			shadow_quality = 2.5

	# Auflösungsskalierung
	ProjectSettings.set_setting("rendering/scaling_3d/scale", resolution_scale)

	# Anti-Aliasing
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", msaa_level)

	# Schattenqualität
	ProjectSettings.set_setting("rendering/lights_and_shadows/directional_shadow/size", 4096*shadow_quality)

	# FOV
	#for camera in get_tree().get_nodes_in_group("cameras"):
	#	camera.fov = fov

	# Audio
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"), 
		linear_to_db(master_volume)
	)

func save_settings():
	var data = {
		"max_fps": max_fps,
		"graphics_quality": graphics_quality,
		"resolution_scale": resolution_scale,
		"msaa_level": msaa_level,
		"shadow_quality": shadow_quality,
		"texture_lod_bias": texture_lod_bias,
		"fov": fov,
		"mouse_sensitivity": mouse_sensitivity,
		"master_volume": master_volume
			}
	var file = FileAccess.open("user://settings.save", FileAccess.WRITE)
	file.store_var(data)
	file.close()

func load_settings():
	if FileAccess.file_exists("user://settings.save"):
		var file = FileAccess.open("user://settings.save", FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		var props = []
		for p in get_property_list():
			props.append(p.name)
		
		for key in data.keys():
			if key in props:
				set(key, data[key])
		
		apply_settings()
