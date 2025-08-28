## Class: TimeController
##
## Example of a node connection with this class:
##
## TimerController.register_character_callback(callable)

extends Node

## Emitted whenever the game speed changes (including pause/resume)
signal speed_changed(new_speed: float)

## Holds all possible game speeds to use.
enum Speed {
	PAUSED = 0,   # x0
	SLOW = 1,     # x0.5
	NORMAL = 2,   # x1
	FAST = 4,     # x2
}

## Indicates the current game speed.
var current_speed: float

## Holds the last speed selected before the current.
var last_speed: float

## Indicates if the game is paused or not
var paused: bool = false


func _init() -> void:
	set_speed(Speed.NORMAL)


# Comment this function if you don't want keybinds for time control
func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_SPACE):
			set_speed(Speed.PAUSED)
	elif Input.is_key_pressed(KEY_1):
		set_speed(Speed.SLOW)
	elif Input.is_key_pressed(KEY_2):
		set_speed(Speed.NORMAL)
	elif Input.is_key_pressed(KEY_3):
		set_speed(Speed.FAST)
	elif Input.is_key_pressed(KEY_HOME):
		debug_print_status()


## Called when a new game speed is requested.
func set_speed(new: int) -> void:
	if new != Speed.PAUSED:
		last_speed = current_speed
		
	current_speed = _enum_to_scale(new)
	_emit_speed_changed()
	_apply_speed_to_engine(current_speed)


## Converts enum value to actual time scale (divides by 2 because enums
## cannot be float)
static func _enum_to_scale(speed: float) -> float:
	return speed / 2


## Called when a pause request is emitted.
## Pauses the game.
func pause() -> void:
	current_speed = Speed.PAUSED
	_emit_speed_changed()
	_apply_speed_to_engine(current_speed)


## Called when a unpause request is emitted.
## Resumes the game using the last speed selected.
func resume() -> void:
	current_speed = last_speed
	_emit_speed_changed()
	_apply_speed_to_engine(current_speed)


## Called when time speed needs to be resetted.
func reset() -> void:
	set_speed(Speed.NORMAL)

## Sets the engine time scale to sync with this TimeController speed.
static func _apply_speed_to_engine(speed: float) -> void:
	Engine.time_scale = speed

## Called when delta needs to be synchronized on a physics process
func scaled_delta(delta: float) -> float:
	return delta * current_speed

#region CALLBACKS

## Callback list for characters (CharacterBody2D or CharacterBody3D)
var character_callbacks : Array[Callable] = []

## Callback list for animations (AnimationPlayer)
var animation_callbacks : Array[Callable] = []

## Callback list for game user interfaces (ProgressBar, Timer and others)
var gui_callbacks : Array[Callable] = []

## Callback list for static interfaces (menus and buttons)
var ui_callbacks : Array[Callable] = []

## Callback list for sound effects (SFX)
var sfx_callbacks : Array[Callable] = []

## Callback list for background music / soundtrack
var soundtrack_callbacks : Array[Callable] = []


## Registers a callback for characters (CharacterBody2D / CharacterBody3D)
## The callback must be a Callable with one float argument (new_speed)
## Example: TimeController.register_character_callback(Callable.new(self, "_on_speed_changed"))
func register_character_callback(cb: Callable) -> void:
	var obj = cb.get_object()
	
	if obj:
		if obj is CharacterBody2D or obj is CharacterBody3D or obj is Sprite2D:
			character_callbacks.append(cb)
		else:
			printerr("Callable [%s] belongs to type [%s] and is not valid for the CHARACTER list!" %
			[cb.get_method(), obj.get_class()])


## Registers a callback for animations (AnimationPlayer, Tween)
## The callback must be a Callable with one float argument (new_speed)
func register_animation_callback(cb: Callable) -> void:
	var obj = cb.get_object()
	
	if obj:
		if obj is AnimationPlayer:
			animation_callbacks.append(cb)
		else:
			printerr("Callable [%s] belongs to type [%s] and is not valid for the ANIMATION list!" %
			[cb.get_method(), obj.get_class()])


## Registers a callback for game HUD/UI elements (ProgressBar, Timer, etc.)
## The callback must be a Callable with one float argument (new_speed)
func register_gui_callback(cb: Callable) -> void:
	var obj = cb.get_object()
	
	if obj:
		if obj is ProgressBar or obj is Timer:
			gui_callbacks.append(cb)
		else:
			printerr("Callable [%s] belongs to type [%s] and is not valid for the GUI list!" %
			[cb.get_method(), obj.get_class()])


## Registers a callback for static UI elements (menus, buttons, etc.)
## The callback must be a Callable with one float argument (new_speed)
func register_ui_callback(cb: Callable) -> void:
	var obj = cb.get_object()
	
	if obj:
		if obj is Button or obj is TextureRect or obj is Label:
			ui_callbacks.append(cb)
		else:
			printerr("Callable [%s] belongs to type [%s] and is not valid for the UI list!" %
			[cb.get_method(), obj.get_class()])


## Registers a callback for sound effects (sounds, noise)
## The callback must be a Callable with one float argument (new_speed)
func register_sfx_callback(cb: Callable) -> void:
	var obj = cb.get_object()
	
	if obj:
		if obj is AudioStreamPlayer:
			sfx_callbacks.append(cb)
		else:
			printerr("Callable [%s] belongs to type [%s] and is not valid for the SFX list!" %
			[cb.get_method(), obj.get_class()])


## Registers a callback for soundtracks (music, soundtracks)
## The callback must be a Callable with one float argument (new_speed)
func register_soundtrack_callback(cb: Callable) -> void:
	var obj = cb.get_object()
	
	if obj:
		if obj is AudioStreamPlayer:
			soundtrack_callbacks.append(cb)
		else:
			printerr("Callable [%s] belongs to type [%s] and is not valid for the SOUNDTRACK list!" %
			[cb.get_method(), obj.get_class()])


## Called whenever the game speed changes.
## If `category` is provided, only callbacks in that category will be triggered.
func _emit_speed_changed(categories: Array[String] = []) -> void:
	# Signal emitted
	emit_signal("speed_changed", current_speed)
	
	# If array is empty, calls all callbacks
	if categories.size() < 1:
		categories = ["character","animation","gui","ui","sfx","soundtrack"]
	
	var cat_dict: Dictionary = {
		"character": character_callbacks,
		"animation": animation_callbacks,
		"gui": gui_callbacks,
		"ui": ui_callbacks,
		"sfx": sfx_callbacks,
		"soundtrack": soundtrack_callbacks,
	}
	
	for cat in categories:
		if cat_dict.has(cat):
			for cb in cat_dict[cat]:
				cb.call(current_speed)
		else:
			printerr("Category [%s] doesn't exists!" % cat)

#endregion


## Called when debug prints are requested.
## Prints the current speed, last speed and callbacks
func debug_print_status() -> void:
	print_rich("[b]================ TimeController Status ================")
	print()
	print("Current Speed: ", current_speed)
	print("Last Speed: ", last_speed)
	print()
	
	var categories = {
		"character": character_callbacks,
		"animation": animation_callbacks,
		"gui": gui_callbacks,
		"ui": ui_callbacks,
		"sfx": sfx_callbacks,
		"soundtrack": soundtrack_callbacks
	}
	
	for cat_name in categories.keys():
		var list = categories[cat_name]
		print_rich("\n[color=#5ecc9d]Category: ", cat_name, " | Callbacks: [b]", list.size())
		for cb in list:
			var obj = cb.get_object()
			var method = cb.get_method()
			var type_name = obj.get_class() if obj else "null"
			print(" - [b][", method, "][/b] belongs to [b][", type_name, "][/b] called [b][", obj.name, "]")
	print_rich("\n[b]======================================================")
