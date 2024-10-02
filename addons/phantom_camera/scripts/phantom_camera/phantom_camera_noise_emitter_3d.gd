@tool
@icon("res://addons/phantom_camera/icons/phantom_camera_noise_emitter_3d.svg")
class_name PhantomCameraNoiseEmitter3D
extends Node3D

const _constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

#region Exported Properties

## If true, previews the noise in the Viewfinder.
@export var preview: bool = false:
	set(value):
		preview = value
		_play = value
	get:
		return preview

## If true, repeats the noise indefinitely once started.Otherwise, it will only be triggered once. [br]
## [b]Note:[/b] This will always be enabled if the resource is assigned the the [PhantomCamera3D]'s
## [member PhantomCamera3D.noise] property.
@export var continous: bool = false:
	set(value):
		continous = value
		notify_property_list_changed()
	get:
		return continous

## Determines how long the noise should take to reach full [member intensity] once started.[br]
## The value is set in [b]seconds[/b].
@export_exp_easing("positive_only") var growth_time: float = 0

## Sets the duration for the camera noise if [member loop] is set to false.[br]
## If the duration is [param 0] then [member continous] becomes enabled.[br]
## The value is set in [b]seconds[/b].
@export_range(0, 10, 0.001, "or_greater", "suffix: s") var duration: float = 1.0:
	set(value):
		duration = value
		if duration == 0:
			duration = 0.001
	get:
		return duration

## Determines how long the noise should take to come to a full stop.[br]
## The value is set in [b]seconds[/b].
@export_exp_easing("attenuation", "positive_only") var decay_time: float = 0

## Enabled layers will affect [PhantomCamera3D] nodes with at least one corresponding layer enabled.[br]
## Enabling multiple corresponding layers on the same [PhantomCamera3D] causes no additional effect.
@export_flags_3d_render var noise_emitter_layer = 1

## The resource that defines the noise pattern.[br]
## [b]Note:[/b] This is a required property and so will always have a default value.
@export var noise: PhantomCameraNoise3D:
	set(value):
		noise = value
		update_configuration_warnings()
	get:
		return noise

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
			if noise.randomize_seed:
				noise.seed = randi() & 1000
			else:
				noise.reset_noise_time()
	get:
		return _play

var _start_duration_countdown: bool = false

var _decay_countdown: float = 0

var _should_grow: bool = false

var _should_decay: bool = false

var _elasped_play_time: float = 0

var _noise_output: Transform3D = Transform3D()

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
	if property.name == "duration" and continous:
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

	if not continous:
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
	_phantom_camera_manager.noise_3d_emitted.emit(_noise_output, noise_emitter_layer)

#endregion

#region Public Functions

func assign_noise_resource(resource: PhantomCameraNoise3D) -> void:
	noise = resource


func emit() -> void:
	if _play: _play = false
	_play = true


func stop(should_decay: bool = true) -> void:
	if should_decay:
		_should_decay = true
	else:
		_play = false


func toggle() -> void:
	_play = !_play

#endregion
