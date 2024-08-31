@tool
class_name PhantomCameraNoiseEmitter3D
extends Node

const _constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

## If true, previews the noise in the Viewfinder.
@export var play: bool = false:
	set(value):
		play = value

		if play:
			_should_grow = true
			_duration_countdown = false
			_should_decay = false
			_elasped_play_time = 0
		else:
			_should_decay = false
	get:
		return play


## If true, repeats the noise indefinitely once started.Otherwise, it will only be triggered once. [br]
## [b]Note:[/b] This will always be enabled if the resource is assigned the the [PhantomCamera3D]'s
## [member PhantomCamera3D.noise] property.
@export var continous: bool = false:
	set(value):
		continous = value
		notify_property_list_changed()
	get:
		return continous


## Sets the duration for the camera noise if [member loop] is set to false.[br]
## If the duration is [param 0] then [member continous] becomes enabled.[br]
## The value is set in [b]seconds[/b].
@export_range(0, 10, 0.001, "or_greater", "suffix: s") var duration: float = 1.0:
	set(value):
		duration = value
		if duration == 0:
			continous = true
			notify_property_list_changed()
			duration = 1.0
	get:
		return duration


## Determines how long the noise should take to reach full [member intensity] once started.[br]
## The value is set in [b]seconds[/b].
@export_exp_easing("positive_only") var growth_time: float = 0


## Determines how long the noise should take to come to a full stop.[br]
## The value is set in [b]seconds[/b].
@export_exp_easing("attenuation", "positive_only") var decay_time: float = 0


## Enabled layers will affect [PhantomCamera3D] nodes with at least one corresponding layer enabled.[br]
## Enabling multiple corresponding layers on the same [PhantomCamera3D] causes no additional effect.
@export_flags_3d_render var noise_emitter_layers = 1


## If true, will only be triggered once the parent PCam has become active.
## This property is only visible if the emitter is a child of a PCam.
@export var trigger_after_tween: bool


## The resource that defines the noise pattern.[br]
## [b]Note:[/b] This is a required property and so will always have a default value.
@export var noise: PhantomCameraNoise3D:
	set(value):
		noise = value
		notify_property_list_changed()
	get:
		return noise

var _duration_countdown: bool = false

var _should_grow: bool = false
var _should_decay: bool = false

var _elasped_play_time: float = 0

var _pcam_parent: PhantomCamera3D
var _has_parent_pcam: bool = true

var _noise_output: Transform3D

# NOTE - Temp solution until Godot has better plugin autoload recognition out-of-the-box.
var _phantom_camera_manager: Node


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
	if not play and not _should_decay: return

	_elasped_play_time += delta

	if _should_grow:
		noise.set_trauma(minf(_elasped_play_time / growth_time, 1))
		if _elasped_play_time >= growth_time:
			print("Finished growth")
			_should_grow = false
			_duration_countdown = true
			noise.set_trauma(1)

	if not continous:
		if _duration_countdown:
			if _elasped_play_time >= duration + growth_time:
				print("Finished duration")
				_should_decay = true
				_duration_countdown = false

	if _should_decay:
		noise.set_trauma(maxf(1 - (_elasped_play_time - decay_time) / (duration + growth_time), 0))
		if _elasped_play_time >= duration + growth_time + decay_time:
			print("Finished decay")
			noise.set_trauma(0)
			play = false
			_should_decay = false
			_elasped_play_time = 0

	_phantom_camera_manager.noise_emitter_3d_triggered.emit(noise, delta)

#endregion


#region Public Functions

func assign_noise_resource(resource: PhantomCameraNoise3D) -> void:
	noise = resource


	#if noise.rotational_noise:
		#_pcam_parent.noise_rotation = noise.noise_rotation(_pcam_parent.rotation_degrees, delta)
		##_pcam_parent
#
	#if noise.positional_noise:


## TODO MIGHT NOT BE NEEDED
#func enable_continous(caller: Node, value: bool) -> void:
	#if caller.is_class("PhantomCamera3D"):
		#_stay_continous = value

#endregion
