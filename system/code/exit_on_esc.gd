extends Node


func _ready():
	set_process_input(true)

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
		
func _on_anim_totem_animation_finished(anim_name):
	get_tree().change_scene('game/scenes/game_over.tscn')
