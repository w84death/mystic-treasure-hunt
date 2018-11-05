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
	$GUI/HUD/right/compas.refresh(current_dir)

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

	if Input.is_action_pressed("ui_left"):
		rotate_left()
	if Input.is_action_pressed("ui_right"):
		rotate_right()
	if Input.is_action_pressed("ui_up"):
		move_forward()
	if Input.is_action_pressed("ui_down"):
		move_backward()

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
	
func set_direction(dir):
	current_dir += dir
	
	if current_dir > 3:
		current_dir = 0
		
	if current_dir < 0:
		current_dir = 3
		
	$GUI/HUD/right/compas.refresh(current_dir)
		
func rotate_left():
	angle_y += 90
	set_direction(-1)
	
func rotate_right():
	angle_y -= 90
	set_direction(1)
	
func move_forward():
	move_to += directions[current_dir];

func move_backward():
	move_to -= directions[current_dir];
	
	
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
		
func get_adjustet_height(pos):
	var h = get_height(pos).r;
	
	if (h > mountains_level):
		h += (h-mountains_level)*mountains_size;
		
	return terrain_height * h * terrain_scale + camera_height_offset;
	
func _physics_process(delta):
	for axis in range(JOY_AXIS_0, JOY_AXIS_MAX):
		axis_value = Input.get_joy_axis(0, axis)
		var axis_abs = abs(axis_value)
		if axis_abs > DEADZONE:
			# ROTATE LEFT - RIGHT
			if axis == JOY_ANALOG_RX:
				if axis_value > 0:
					angle_y -= rotate_speed * axis_abs
				else:
					angle_y += rotate_speed * axis_abs
					
			# ROTATE ..THE OTEHR WAY :P
			if axis == JOY_ANALOG_RY:
				if axis_value > 0:
					if angle_x > -25:
						angle_x -= rotate_speed * axis_abs
				else:
					if angle_x < 25:
						angle_x += rotate_speed * axis_abs

			# MOVE LEFT - RIGHT
			if axis == JOY_ANALOG_LX:
				if axis_value < 0:
					var left_right = transform.basis.x
					left_right.y = 0.0
					left_right = left_right.normalized()
					move_to -= left_right * move_speed_lr * axis_abs;
				else:
					var left_right = transform.basis.x
					left_right.y = 0.0
					left_right = left_right.normalized()
					move_to += left_right * move_speed_lr * axis_abs;

			# MOVE FRONT - BACK
			if axis == JOY_ANALOG_LY:
				if axis_value < 0:
					var front_back = transform.basis.z
					front_back.y = 0.0
					front_back = front_back.normalized()
					move_to -= front_back * move_speed_fb * abs(axis_value);
				else:
					var front_back = transform.basis.z
					front_back.y = 0.0
					front_back = front_back.normalized()
					move_to += front_back * move_speed_fb * abs(axis_value);
			
func get_height(pos):
	var px = Color(0,0,0);
	if pos.x >= 0 && pos.y >= 0 && pos.x < map_size.x && pos.y < map_size.y:
		height_map.lock()
		px = height_map.get_pixel(pos.x, pos.y)
		height_map.unlock()
	return px

func _on_a_pressed():
	pass

func _on_x_pressed():
	if $GUI/HUD/center/map.visible:
		$GUI/HUD/center/map.hide()
	else:
		$GUI/HUD/center/map.show()
