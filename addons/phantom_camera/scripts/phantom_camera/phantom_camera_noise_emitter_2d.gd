@tool
@icon("res://addons/phantom_camera/icons/phantom_camera_noise_emitter_2d.svg")
class_name PhantomCameraNoiseEmitter2D
extends Node2D

## Emits positional and rotational noise to active [PhantomCamera2D]s and its corresponding [Camera2D].
##
## Is a node meant to apply positional and rotational noise, also referred to as shake, to the [Camera2D].
## It is designed for use cases such as when hitting or when being hit, earthquakes or to add a
## bit of slight movement to the camera to make it feel less static.
## The emitter can affect multiple [PhantomCamera2D] in a given scene based on which [member noise_emitter_layer]
## are enabled by calling its [method emit] function. At least one corresponding layer has to be
## set on the [PhantomCamera2D] and the emitter node.

const _constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

#region Exported Proerpties

## The [PhantomCameraNoise2D] resource that defines the noise pattern.
@export var noise: PhantomCameraNoise2D = null:
	set = set_noise,
	get = get_noise

## If true, previews the noise in the editor - can be seen in the viewfinder.
@export var preview: bool = false:
	set(value):
		preview = value
		_play = value
	get:
		return preview

## If true, repeats the noise indefinitely once started. Otherwise, it will only be triggered once. [br]
@export var continuous: bool = false:
	set = set_continuous,
	get = get_continuous

## Determines how long the noise should take to reach full [member intensity] once started.[br]
## The value is set in [b]seconds[/b].
@export_exp_easing("positive_only", "suffix: s") var growth_time: float = 0:
	set = set_growth_time,
	get = get_growth_time

## Sets the duration for the camera noise if [member continuous] is set to [b]false[/b].[br][br]
## The value is set in [b]seconds[/b].
@export_range(0, 10, 0.001, "or_greater", "suffix: s") var duration: float = 1.0:
	set = set_duration,
	get = get_duration

## Determines how long the noise should take to come to a full stop.[br]
## The value is set in [b]seconds[/b].
@export_exp_easing("attenuation", "positive_only", "suffix: s") var decay_time: float = 0:
	set = set_decay_time,
	get = get_decay_time

## Enabled layers will affect [PhantomCamera2D] nodes with at least one corresponding layer enabled.[br]
## Enabling multiple corresponding layers on the same [PhantomCamera2D] causes no additional effect.
@export_flags_2d_render var noise_emitter_layer: int = 1:
	set = set_noise_emitter_layer,
	get = get_noise_emitter_layer

#endregion


#region Private Variables

var _play: bool = false:
	set(value):
		_play = value
		if value:
			_elasped_play_time = 0
			_decay_countdown = 0
			_play = true
			_should_grow = true
			_start_duration_countdown = false
			_should_decay = false
		else:
			_should_decay = true
			if noise.randomize_noise_seed:
				noise.noise_seed = randi() & 1000
			else:
				noise.reset_noise_time()
	get:
		return _play

var _start_duration_countdown: bool = false

var _decay_countdown: float = 0

var _should_grow: bool = false

var _should_decay: bool = false

var _elasped_play_time: float = 0

var _noise_output: Transform2D = Transform2D()

# NOTE - Temp solution until Godot has better plugin autoload recognition out-of-the-box.
var _phantom_camera_manager: Node

#endregion

#region Private Functions

func _get_configuration_warnings() -> PackedStringArray:
	if noise == null:
		return ["Noise resource is required in order to trigger emitter."]
	else:
		return []


func _validate_property(property) -> void:
	if property.name == "duration" and continuous:
		property.usage = PROPERTY_USAGE_NO_EDITOR


func _enter_tree() -> void:
	_phantom_camera_manager = get_tree().root.get_node(_constants.PCAM_MANAGER_NODE_NAME)


func _process(delta: float) -> void:
	if not _play and not _should_decay: return
	if noise == null:
		printerr("Noise resource missing in ", name)
		_play = false
		return

	_elasped_play_time += delta

	if _should_grow:
		noise.set_trauma(minf(_elasped_play_time / growth_time, 1))
		if _elasped_play_time >= growth_time:
			_should_grow = false
			_start_duration_countdown = true
			noise.set_trauma(1)
	else:
		noise.set_trauma(1)

	if not continuous:
		if _start_duration_countdown:
			if _elasped_play_time >= duration + growth_time:
				_should_decay = true
				_start_duration_countdown = false

	if _should_decay:
		_decay_countdown += delta
		noise.set_trauma(maxf(1 - (_decay_countdown / decay_time), 0))
		if _decay_countdown >= decay_time:
			noise.set_trauma(0)
			_play = false
			preview = false
			_should_decay = false
			_elasped_play_time = 0
			_decay_countdown = 0

	_noise_output = noise.get_noise_transform(delta)
	_phantom_camera_manager.noise_2d_emitted.emit(_noise_output, noise_emitter_layer)


func _set_layer(current_layers: int, layer_number: int, value: bool) -> int:
	var mask: int = current_layers

	# From https://github.com/godotengine/godot/blob/51991e20143a39e9ef0107163eaf283ca0a761ea/scene/3d/camera_3d.cpp#L638
	if layer_number < 1 or layer_number > 20:
		printerr("Layer must be between 1 and 20.")
	else:
		if value:
			mask |= 1 << (layer_number - 1)
		else:
			mask &= ~(1 << (layer_number - 1))

	return mask

#endregion


#region Public Functions

## Emits noise to the [PhantomCamera2D]s that has at least one matching layers.
func emit() -> void:
	if _play: _play = false
	_play = true

## Returns the state for the emitter. If true, the emitter is currently emitting.
func is_emitting() -> bool:
	return _play

## Stops the emitter from emitting noise.
func stop(should_decay: bool = true) -> void:
	if should_decay:
		_should_decay = true
	else:
		_play = false

## Toggles the emitter on and off.
func toggle() -> void:
	_play = !_play

#endregion


#region Setter & Getter Functions

## Sets the [member noise] resource.
func set_noise(value: PhantomCameraNoise2D) -> void:
	noise = value
	update_configuration_warnings()

## Returns the [member noise] resource.
func get_noise() -> PhantomCameraNoise2D:
	return noise


## Sets the [member continous] value.
func set_continuous(value: bool) -> void:
	continuous = value
	notify_property_list_changed()

## Gets the [member continous] value.
func get_continuous() -> bool:
	return continuous


## Sets the [member growth_time] value.
func set_growth_time(value: float) -> void:
	growth_time = value

## Returns the [member growth_time] value.
func get_growth_time() -> float:
	return growth_time


## Sets the [member duration] value.
func set_duration(value: float) -> void:
	duration = value
	if duration == 0:
		duration = 0.001

## Returns the [member duration] value.
func get_duration() -> float:
	return duration


## Sets the [member decay_time] value.
func set_decay_time(value: float) -> void:
	decay_time = value

## Returns the [member decay_time] value.
func get_decay_time() -> float:
	return decay_time


## Sets the [member noise_emitter_layer] value.
func set_noise_emitter_layer(value: int) -> void:
	noise_emitter_layer = value

## Enables or disables a given layer of the [member noise_emitter_layer] value.
func set_noise_emitter_value(value: int, enabled: bool) -> void:
	noise_emitter_layer = _set_layer(noise_emitter_layer, value, enabled)

## Returns the [member noise_emitter_layer] value.
func get_noise_emitter_layer() -> int:
	return noise_emitter_layer

#endregion