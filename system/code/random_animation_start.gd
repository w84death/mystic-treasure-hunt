extends AnimationPlayer



func _ready():
	randomize()
	play("idle")
	seek(randf()*get_current_animation_length())


