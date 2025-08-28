extends CanvasLayer

signal toggle_visible

@onready var pause: NinePatchRect = $Horizontal/Pause/Pause
@onready var slow: NinePatchRect = $Horizontal/Slow/Slow
@onready var normal: NinePatchRect = $Horizontal/Normal/Normal
@onready var fast: NinePatchRect = $Horizontal/Fast/Fast

func _ready() -> void:
	toggle_visible.connect(_change_visibility)

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_F2):
		self.visible = not visible
		toggle_visible.emit()


func _change_visibility() -> void:
	var default_size: Vector2 = Vector2(40,40)
	
	pause.size = default_size
	slow.size = default_size
	normal.size = default_size
	fast.size = default_size
	
	# Buttons
	$Horizontal/Pause/Pause/Pause.disabled = not visible
	$Horizontal/Normal/Normal/Normal.disabled = not visible
	$Horizontal/Fast/Fast/Fast.disabled = not visible
	$Horizontal/Slow/Slow/Slow.disabled = not visible
