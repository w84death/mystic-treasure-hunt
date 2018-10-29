extends AnimationPlayer


func _ready():
	play("idle")
	seek(randf()*get_current_animation_length())


