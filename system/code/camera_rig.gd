extends Position3D

export var rotate_speed = 1.0;
export var move_speed_lr = 0.5;
export var move_speed_fb = 1.5;
export var terrain_height = 64;
export var terrain_scale = 4.0;
export var mountains_level = 0.22;
export var mountains_size = 3.0;
export var water_height = 64*.3;
export var map_size = Vector2(1024, 1024);
export var move_fov_zoom = false;
export var camera_height_offset = 12.0;
const DEADZONE = 0.05;

var angle_x = 0;
var angle_y = 0;

var _angle_x = -24;
var _angle_y = 0;

var height_map;
var move_to;
var axis_value;

var current_dir = 0;
var directions = [
	Vector3(0,0,-128),
	Vector3(128,0,0),
	Vector3(0,0,128),
	Vector3(-128,0,0),
];

func _ready():
	move_to = transform.origin
	var tex = $HUD/right/map.get_texture()
	height_map = tex.get_data()
	$GUI/HUD/right/compass.refresh(current_dir)

func _process(delta):
	if angle_x != _angle_x or angle_y != _angle_y:
		_angle_x += (angle_x - _angle_x) * delta * 10.0;
		_angle_y += (angle_y - _angle_y) * delta * 10.0;

		var basis = Basis(Vector3(0.0, 1.0, 0.0), deg2rad(_angle_y))
		basis *= Basis(Vector3(1.0, 0.0, 0.0), deg2rad(_angle_x))
		transform.basis = basis
		
	if move_to != transform.origin:
		var pos = Vector2(int(map_size.x*.5+transform.origin.x/terrain_scale), int(map_size.y*.5+transform.origin.z/terrain_scale));
		move_to.y = get_adjustet_height(pos)
		if move_to.y < water_height:
			move_to.y = water_height
		transform.origin += (move_to - transform.origin) * delta * 10.0



func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

	if Input.is_action_pressed("game_rotate_left"):
		rotate_left()
	if Input.is_action_pressed("game_rotate_right"):
		rotate_right()
	if Input.is_action_pressed("game_up"):
		move_forward()
	if Input.is_action_pressed("game_down"):
		move_backward()
	if Input.is_action_pressed("game_left"):
		move_left()
	if Input.is_action_pressed("game_right"):
		move_right()
	
	if Input.is_action_pressed("game_x"):
		toggle_map()

func _on_turn_left_pressed():
	rotate_left()

func _on_front_pressed():
	move_forward()

func _on_turn_righ_pressed():
	rotate_right()

func _on_left_pressed():
	pass

func _on_back_pressed():
	move_backward()

func _on_right_pressed():
	pass

func _on_a_pressed():
	pass

func _on_x_pressed():
	toggle_map()
	
func toggle_map():
	if $GUI/HUD/center/map.visible:
		$GUI/HUD/center/map.hide()
	else:
		$GUI/HUD/center/map.show()
	
	
func set_direction(dir):
	current_dir += dir
	
	if current_dir > 3:
		current_dir = 0
		
	if current_dir < 0:
		current_dir = 3
		
	$GUI/HUD/right/compass.refresh(current_dir)
		
func rotate_left():
	angle_y += 90
	set_direction(-1)
	
func rotate_right():
	angle_y -= 90
	set_direction(1)
	
func move_forward():
	move_to += directions[current_dir];
	$"GUI/HUD/hud-anim".play("jump")

func move_backward():
	move_to -= directions[current_dir];
	$"GUI/HUD/hud-anim".play("jump")

func move_left():
	pass
	
func move_right():
	pass





func get_adjustet_height(pos):
	var h = get_height(pos).r;
	
	if (h > mountains_level):
		h += (h-mountains_level)*mountains_size;
		
	return terrain_height * h * terrain_scale + camera_height_offset;

func get_height(pos):
	var px = Color(0,0,0);
	if pos.x >= 0 && pos.y >= 0 && pos.x < map_size.x && pos.y < map_size.y:
		height_map.lock()
		px = height_map.get_pixel(pos.x, pos.y)
		height_map.unlock()
	return px


