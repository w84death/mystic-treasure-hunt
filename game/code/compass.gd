extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func refresh(dir):
	if dir == 0: 
		$n.set_text("▲")
		$current.set_text("N")
	else: $n.set_text("△")
	
	if dir == 1: 
		$e.set_text("▶") 
		$current.set_text("E")
	else: $e.set_text("▷")
	
	if dir == 2: 
		$s.set_text("▼") 
		$current.set_text("S")
	else: $s.set_text("▽")
	
	if dir == 3: 
		$w.set_text("◀") 
		$current.set_text("W")
	else: $w.set_text("◁")