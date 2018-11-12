extends RigidBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	restart()
	randomize_numbers()
	set_process_input(true)

func _input(event):
	if Input.is_key_pressed(KEY_ENTER):
		restart()
		randomize_numbers()
	if Input.is_key_pressed(KEY_I):
		get_result()
		
func randomize_numbers():
	rotate_x(randf()*360)
	rotate_y(randf()*360)
	rotate_z(randf()*360)
	
func restart():
	translation = (Vector3(-12.0 + randf()*24.0, 70.0 + randf() * 10.0, -12.0 + randf()*24.0))

func get_result():
	print(get_rotation().x)