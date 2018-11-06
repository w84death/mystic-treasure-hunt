extends MeshInstance

func _ready():
	pass

func use():
	$light.visible = true;


func _on_a_pressed():
	use()
