extends Node

onready var maps = [
	null,
	preload('res://game/maps/s0e1/terrain.tscn'),
	preload('res://game/maps/s0e2/terrain.tscn')
]
var active_season = 0
var active_episode = 0

func _ready():
	run_map_specific_tasks(0, 0)

func play_episode(s, e):
	if (s == active_season and e == active_episode): return

	if($map.get_child_count() > 0):
		$map.remove_child($map.get_child(0))
	$map.add_child(maps[e].instance())
	active_season = s
	active_episode = e
	$PLAYER.GAME_MODE = 1
	$PLAYER/GUI/HUD.show()
	run_map_specific_tasks(s, e)
	
func run_map_specific_tasks(s, e):
	$PLAYER/torch.hide()
	
	if s == 0:
		if e == 0:
			$PLAYER/GUI/HUD.hide()
			$PLAYER/GUI/middle/mapchooser.show()
			$PLAYER/GUI/middle/mapchooser/welcome/buttons/button_s0e1.grab_focus()
		if e == 2:
			$PLAYER/torch.show()
	
	
func _input(event):
	if Input.is_key_pressed(KEY_1): play_episode(0,1)
	if Input.is_key_pressed(KEY_2): play_episode(0,2)
	
func _on_button_s0e1_pressed():
	$PLAYER/GUI/middle/mapchooser.hide()
	play_episode(0,1)

func _on_button_s0e2_pressed():
	$PLAYER/GUI/middle/mapchooser.hide()
	play_episode(0,2)

func _on_y_pressed():
	if($PLAYER/GUI/middle/mapchooser.is_visible_in_tree()):
		$PLAYER/GUI/middle/mapchooser.hide()
	else:
		$PLAYER/GUI/middle/mapchooser.show()
