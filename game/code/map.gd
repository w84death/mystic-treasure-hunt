extends NinePatchRect

export var MAP_SCALING = 4;

func _ready():
	pass # Replace with function body.

func refresh_map(pos, dir):
	$poi/here.set_position(pos * MAP_SCALING)