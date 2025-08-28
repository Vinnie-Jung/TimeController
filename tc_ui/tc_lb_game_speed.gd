extends Label

func _process(_delta: float) -> void:
	self.text = "Game Speed: x" + str(TimeController.current_speed)
