extends Particles

export var terrain_height = 64
export var terrain_scale = 4.0
export var rows = 256
export var spacing = 4.0

func update_aabb():
	var size = rows * spacing
	visibility_aabb = AABB(
		Vector3(-0.5 * size, 0.0, -0.5 * size), #x,y,z
		Vector3(size, terrain_height * terrain_scale, size)) #w,up,h;

func _ready():
	update_aabb()

func _process(delta):
	# Center our particles on our cameras position
	var viewport = get_viewport()
	var camera = viewport.get_camera()

	var pos = camera.global_transform.origin
	pos.y = 0.0
	global_transform.origin = pos