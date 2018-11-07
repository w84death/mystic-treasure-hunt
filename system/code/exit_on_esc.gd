extends Node


func _ready():
	set_process_input(true)

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		exit_from_this_game()

func _on_exit_pressed():
	exit_from_this_game()

func exit_from_this_game():
	get_tree().quit()