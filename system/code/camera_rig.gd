extends Position3D

export var GAME_MODE = 0;
export var rotate_speed = 8.0;
export var move_speed = 8.0;
export var terrain_height = 64;
export var terrain_scale = 0.125;
export var mountains_level = 0.44;
export var mountains_size = 3.0;
export var water_height = 0.1;
export var map_size = Vector2(2048, 2048);
export var pixel_map_size = Vector2(64, 64);
export var camera_offset_height = 2.0;
export var camera_angle_scale = 24.0;
const DEADZONE = 0.05;

var angle_x = 0;
var angle_y = 0;

var _angle_x = -24;
var _angle_y = 0;

var height_map;
var pixel_map;
var move_to;

export var current_position = Vector2(32,32);
var current_dir = 0;
var directions = [
	Vector3(0,0,-4),
	Vector3(4,0,0),
	Vector3(0,0,4),
	Vector3(-4,0,0),
];
var pixel_dir = [
	Vector2(0,-1),
	Vector2(1,0),
	Vector2(0,1),
	Vector2(-1,0),
];

func _ready():
	move_to = transform.origin
	var tex = $"GUI/HUD/right/mini-map/map".get_texture()
	height_map = tex.get_data()
	var tex2 = $"GUI/HUD/right/mini-map/pixel_map".get_texture()
	pixel_map = tex2.get_data()
	$GUI/HUD/right/compass.refresh(current_dir)
	refresh_buttons()

func _process(delta):
	if angle_x != _angle_x or angle_y != _angle_y:
		_angle_x += (angle_x - _angle_x) * delta * rotate_speed;
		_angle_y += (angle_y - _angle_y) * delta * rotate_speed;

		var basis = Basis(Vector3(0.0, 1.0, 0.0), deg2rad(_angle_y))
		basis *= Basis(Vector3(1.0, 0.0, 0.0), deg2rad(_angle_x))
		transform.basis = basis
		
	if move_to != transform.origin:
		var pos = Vector2(int(map_size.x*.5+transform.origin.x/terrain_scale), int(map_size.y*.5+transform.origin.z/terrain_scale));

		move_to.y = get_adjustet_height(pos)
		if move_to.y < water_height:
			move_to.y = water_height
		transform.origin += (move_to - transform.origin) * delta * move_speed



func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	if Input.is_key_pressed(KEY_C):
		cinematic_mode()

	if GAME_MODE > 0:
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
	move_left()

func _on_back_pressed():
	move_backward()

func _on_right_pressed():
	move_right()

func _on_a_pressed():
	pass

func _on_x_pressed():
	toggle_map()
	
func toggle_map():
	if $GUI/HUD/center/map.visible:
		$GUI/HUD/center/map.hide()
	else:
		$GUI/HUD/center/map.show()

func cinematic_mode():
	if $GUI.is_visible_in_tree():
		$GUI.hide()
	else:
		$GUI.show()
	
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
	refresh_buttons()
	adjust_camera_angle()
	
func rotate_right():
	angle_y -= 90
	set_direction(1)
	refresh_buttons()
	adjust_camera_angle()
	
func move_forward():
	if get_pixel_move(current_position+pixel_dir[current_dir]):
		move_to += directions[current_dir];
		current_position += pixel_dir[current_dir]
		$"GUI/HUD/hud-anim".play("jump")
		refresh_buttons()
		adjust_camera_angle()

func move_backward():
	if get_pixel_move(current_position - pixel_dir[current_dir]):
		move_to -= directions[current_dir];
		current_position -= pixel_dir[current_dir]
		$"GUI/HUD/hud-anim".play("jump")
		refresh_buttons()
		adjust_camera_angle()

func move_left():
	var left_dir = current_dir-1;
	if left_dir < 0:
		left_dir = 3;
	
	if get_pixel_move(current_position + pixel_dir[left_dir]):
		move_to += directions[left_dir];
		current_position += pixel_dir[left_dir]
		$"GUI/HUD/hud-anim".play("jump")
		refresh_buttons()
		adjust_camera_angle()
	
func move_right():
	var right_dir = current_dir+1;
	if right_dir > 3:
		right_dir = 0;
	
	if get_pixel_move(current_position + pixel_dir[right_dir]):
		move_to += directions[right_dir];
		current_position += pixel_dir[right_dir]
		$"GUI/HUD/hud-anim".play("jump")
		refresh_buttons()
		adjust_camera_angle()

func adjust_camera_angle():
	var pos = Vector2(
				int(map_size.x*.5+transform.origin.x/terrain_scale), 
				int(map_size.y*.5+transform.origin.z/terrain_scale));
	var current_tile_height = get_adjustet_height(pos)
	var ahead_tile_height = get_adjustet_height(
				pos + Vector2(directions[current_dir].x,
				directions[current_dir].z))
	var slope = ahead_tile_height - current_tile_height;
	angle_x = slope * camera_angle_scale;
	
func get_adjustet_height(pos):
	var h = get_height(pos).r;
	
	if (h > mountains_level):
		h += (h-mountains_level) * mountains_size;

	return terrain_height * h * terrain_scale + camera_offset_height;

func get_height(pos):
	var px = Color(0,0,0);
	if pos.x >= 0 && pos.y >= 0 && pos.x < map_size.x && pos.y < map_size.y:
		height_map.lock()
		px = height_map.get_pixel(pos.x, pos.y)
		height_map.unlock()
	return px
	
func get_pixel_map_data(pos):
	var data = Color(0,0,0);
	if pos.x >= 0 && pos.y >= 0 && pos.x < pixel_map_size.x && pos.y < pixel_map_size.y:
		pixel_map.lock()
		data = pixel_map.get_pixel(pos.x, pos.y)
		pixel_map.unlock()
	return data;

func get_pixel_move(pos):
	if get_pixel_map_data(pos).r > 0.5:
		return true
	else:
		return false
		
func refresh_buttons():
	var left_dir = current_dir-1;
	if left_dir < 0:
		left_dir = 3;
	var right_dir = current_dir+1;
	if right_dir > 3:
		right_dir = 0;
	$GUI/HUD/bottom/movement/VBoxContainer/top/front.disabled = not get_pixel_move(current_position+pixel_dir[current_dir]);
	$GUI/HUD/bottom/movement/VBoxContainer/bottom/right.disabled = not get_pixel_move(current_position + pixel_dir[right_dir]);
	$GUI/HUD/bottom/movement/VBoxContainer/bottom/back.disabled = not get_pixel_move(current_position - pixel_dir[current_dir]);
	$GUI/HUD/bottom/movement/VBoxContainer/bottom/left.disabled = not get_pixel_move(current_position + pixel_dir[left_dir]);
	$GUI/HUD/center/map.refresh_map(current_position, current_dir)
