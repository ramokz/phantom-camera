@tool
@icon("res://addons/phantom_camera/icons/phantom_camera_tween_director.svg")
class_name PhantomCameraTweenDirector
extends Node

## Conditionally overrides [PhantomCameraTween] of [param PhantomCameras].
##
## Using the [TweenDirectorResource], this node allows for custom tweens between specific [param PhantomCameras] in a scene.[br][br]
## Whenever a tween between two [param PhantomCameras] occurs, this node can override the [PhantomCameraTween] applied to the newly active
## [param PhantomCamera] if an instance on both the [b]From[/b] and [b]To[/b] lists match the previously and newly active [param PhantomCamera] respectively.

#region Constants

const _constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

#endregion


#region Public Variables

## Override the [PhantomCameraTween] between specific [param PhantomCameras].
@export var tween_director: Array[TweenDirectorResource] = []:
	set = set_tween_director,
	get = get_tween_director

#endregion


#region Private Variables

var _pcam_manager: Node = null

#endregion


#region Private Functions

func _enter_tree() -> void:
	_pcam_manager = Engine.get_singleton(_constants.PCAM_MANAGER_NODE_NAME)
	if is_instance_valid(_pcam_manager):
		_pcam_manager.pcam_tween_director_added(self)


func _exit_tree() -> void:
	_pcam_manager.pcam_tween_director_removed(self)

#endregion


#region Public Functions

## Sets the [member tween_director] value.
func set_tween_director(value: Array[TweenDirectorResource]) -> void:
	tween_director = value

## Returns the [member tween_director] value.
func get_tween_director() -> Array[TweenDirectorResource]:
	return tween_director

#endregion
