extends NinePatchRect

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$the_menu/start.grab_focus()


func _on_start_pressed():
	get_tree().change_scene('game/scenes/game.tscn')

func _on_config_pressed():
	$config.show()
	$config/ok.grab_focus()

func _on_ok_pressed():
	$config.hide()
	$the_menu/config.grab_focus()
