@tool
@icon("res://addons/phantom_camera/icons/phantom_camera_2d.svg")
class_name PhantomCamera2D
extends Node2D

## Controls a scene's [Camera2D] and applies logic to it.
##
## The scene's [param Camera2D] will follow the position of the
## [param PhantomCamera2D] with the highest priority.
## Each instance can have different positional and rotational logic applied
## to them.

#region Constants

const _constants := preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

#endregion

#region Signals

## Emitted when the [param PhantomCamera2D] becomes active.
signal became_active

## Emitted when the [param PhantomCamera2D] becomes inactive.
signal became_inactive

## Emitted when the follow_mode changes.
## Note: This is for internal use only
signal follow_mode_changed

## Emitted when [member follow_target] changes.
signal follow_target_changed

## Emitted when dead zones changes.[br]
## [b]Note:[/b] Only applicable in [param Framed] [enum FollowMode].
signal dead_zone_changed

## Emitted when a target touches the edge of the dead zone in [param Framed] [enum FollowMode].
signal dead_zone_reached(side: Vector2)

## Emitted when the [param Camera2D] starts to tween to another [param PhantomCamera2D].
signal tween_started

## Emitted when the [param Camera2D] is to tweening towards another [param PhantomCamera2D].
signal is_tweening

## Emitted when the tween is interrupted due to another [param PhantomCamera2D]
## becoming active. The argument is the [param PhantomCamera2D] that interrupted
## the tween.
signal tween_interrupted(pcam_2d: PhantomCamera2D)

## Emitted when the [param Camera2D] completes its tween to the
## [param PhantomCamera2D].
signal tween_completed

## Emitted when Noise should be applied to the Camera2D.
signal noise_emitted(noise_output: Transform2D)

signal physics_target_changed

#endregion

#region Enums

## Determines the positional logic for a given [param PhantomCamera2D]
## [br][br]
## The different modes have different functionalities and purposes, so choosing
## the correct one depends on what each [param PhantomCamera2D] is meant to do.
enum FollowMode {
	NONE    = 0, ## Default - No follow logic is applied.
	GLUED   = 1, ## Sticks to its target.
	SIMPLE  = 2, ## Follows its target with an optional offset.
	GROUP   = 3, ## Follows multiple targets with option to dynamically reframe itself.
	PATH    = 4, ## Follows a target while being positionally confined to a [Path2D] node.
	FRAMED  = 5, ## Applies a dead zone on the frame and only follows its target when it tries to leave it.
}

## Determines how often an inactive [param PhantomCamera2D] should update
## its positional and rotational values. This is meant to reduce the amount
## of calculations inactive [param PhantomCamera2D] are doing when idling to
## improve performance.
enum InactiveUpdateMode {
	ALWAYS, ## Always updates the [param PhantomCamera2D], even when it's inactive.
	NEVER, ## Never updates the [param PhantomCamera2D] when it's inactive. Reduces the amount of computational resources when inactive.
#	EXPONENTIALLY,
}

enum FollowLockAxis {
	NONE    = 0,
	X       = 1,
	Y       = 2,
	XY      = 3,
}

enum FollowTargetPhysicsClass {
	CHARACTERBODY   = 0,
	RIGIDBODY       = 1,
	OTHER           = 2,
}

#endregion

#region Exported Properties

## To quickly preview a [param PhantomCamera2D] without adjusting its
## [member priority], this property allows the selected PCam to ignore the
## Priority system altogether and forcefully become the active one. It's
## partly designed to work within the Viewfinder, and will be disabled when
## running a build export of the game.
@export var priority_override: bool = false:
	set(value):
		priority_override = value
		if Engine.is_editor_hint():
			if value:
				if not Engine.has_singleton(_constants.PCAM_MANAGER_NODE_NAME): return
				Engine.get_singleton(_constants.PCAM_MANAGER_NODE_NAME).pcam_priority_override.emit(self, true)
			else:
				if not Engine.has_singleton(_constants.PCAM_MANAGER_NODE_NAME): return
				Engine.get_singleton(_constants.PCAM_MANAGER_NODE_NAME).pcam_priority_override.emit(self, false)
	get:
		return priority_override


## It defines which [param PhantomCamera2D] a scene's [param Camera2D] should
## be corresponding with and be attached to. This is decided by the PCam with
## the highest [param Priority].
## [br][br]
## Changing [param Priority] will send an event to the scene's
## [PhantomCameraHost], which will then determine whether if the
## [param Priority] value is greater than or equal to the currently
## highest [param PhantomCamera2D]'s in the scene. The [param PhantomCamera2D]
## with the highest value will then reattach the [param Camera2D] accordingly.
@export var priority: int = 0:
	set = set_priority,
	get = get_priority


## Determines the positional logic for a given [param PhantomCamera2D].
## The different modes have different functionalities and purposes, so
## choosing the correct one depends on what each [param PhantomCamera2D]
## is meant to do.
@export var follow_mode: FollowMode = FollowMode.NONE:
	set(value):
		follow_mode = value
		follow_mode_changed.emit()

		if follow_mode == FollowMode.NONE:
			_should_follow = false
			top_level = false
			_is_parents_physics()
			notify_property_list_changed()
			return

		match follow_mode:
			FollowMode.GROUP:
				_follow_targets_size_check()
			FollowMode.PATH:
				if is_instance_valid(follow_path):
					_should_follow_checker()
				else:
					_should_follow = false
			_:
				_should_follow_checker()

		if follow_mode == FollowMode.FRAMED:
			if _follow_framed_initial_set and follow_target:
				_follow_framed_initial_set = false
				dead_zone_changed.connect(_on_dead_zone_changed)
		else:
			if dead_zone_changed.is_connected(_on_dead_zone_changed):
				dead_zone_changed.disconnect(_on_dead_zone_changed)

		top_level = true
		_reset_lookahead()

		notify_property_list_changed()
	get:
		return follow_mode

## Determines which target should be followed.
## The [param Camera2D] will follow the position of the Follow Target
## based on the [member follow_mode] type and its parameters.
@export var follow_target: Node2D = null:
	set = set_follow_target,
	get = get_follow_target

### Defines the targets that the [param PhantomCamera2D] should be following.
@export var follow_targets: Array[Node2D] = []:
	set = set_follow_targets,
	get = get_follow_targets

## Determines the [Path2D] the [param PhantomCamera2D]
## should be bound to.
## The [param PhantomCamera2D] will follow the position of the
## [member follow_target] while sticking to the closest point on this path.
@export var follow_path: Path2D = null:
	set = set_follow_path,
	get = get_follow_path


## Applies a zoom level to the [param PhantomCamera2D], which effectively
## overrides the [param zoom] property of the [param Camera2D] node.
@export_custom(PROPERTY_HINT_LINK, "") var zoom: Vector2 = Vector2.ONE:
	set = set_zoom,
	get = get_zoom


## If enabled, will snap the [param Camera2D] to whole pixels as it moves.
## [br][br]
## This should be particularly useful in pixel art projects,
## where assets should always be aligned to the monitor's pixels to avoid
## unintended stretching.
@export var snap_to_pixel: bool = false:
	set = set_snap_to_pixel,
	get = get_snap_to_pixel


## Enables a preview of what the [PhantomCamera2D] will see in the
## scene. It works identically to how a [param Camera2D] shows which area
## will be visible during runtime. Likewise, this too will be affected by the
## [member zoom] property and the [param viewport_width] and
## [param Viewport Height] defined in the [param Project Settings].
@export var frame_preview: bool = true:
	set(value):
		frame_preview = value
		queue_redraw()
	get:
		return frame_preview


## Defines how the [param PhantomCamera2D] transition between one another.
## Changing the tween values for a given [param PhantomCamera2D]
## determines how transitioning to that instance will look like.
## This is a resource type that can be either used for one
## [param PhantomCamera] or reused across multiple - both 2D and 3D.
## By default, all [param PhantomCameras] will use a [param linear]
## transition, [param easeInOut] ease with a [param 1s] duration.
@export var tween_resource: PhantomCameraTween = PhantomCameraTween.new():
	set = set_tween_resource,
	get = get_tween_resource

## If enabled, the moment a [param PhantomCamera2D] is instantiated into
## a scene, and has the highest priority, it will perform its tween transition.
## This is most obvious if a [param PhantomCamera2D] has a long duration and
## is attached to a playable character that can be moved the moment a scene
## is loaded. Disabling the [param tween_on_load] property will
## disable this behaviour and skip the tweening entirely when instantiated.
@export var tween_on_load: bool = true:
	set = set_tween_on_load,
	get = get_tween_on_load


## Determines how often an inactive [param PhantomCamera2D] should update
## its positional and rotational values. This is meant to reduce the amount
## of calculations inactive [param PhantomCamera2Ds] are doing when idling
## to improve performance.
@export var inactive_update_mode: InactiveUpdateMode = InactiveUpdateMode.ALWAYS


## Determines which layers this [param PhantomCamera2D] should be able to communicate with [PhantomCameraHost] nodes.[br]
## A corresponding layer needs to be set on the [PhantomCameraHost] node.
@export_flags_2d_render var host_layers: int = 1:
	set = set_host_layers,
	get = get_host_layers


@export_group("Follow Parameters")
## Offsets the [member follow_target] position.
@export var follow_offset: Vector2 = Vector2.ZERO:
	set = set_follow_offset,
	get = get_follow_offset

## Applies a damping effect on the [param Camera2D]'s movement.
## Leading to heavier / slower camera movement as the targeted node moves around.
## This is useful to avoid sharp and rapid camera movement.
@export var follow_damping: bool = false:
	set = set_follow_damping,
	get = get_follow_damping

## Defines the damping amount. The ideal range should be somewhere between 0-1.[br][br]
## The damping amount can be specified in the individual axis.[br][br]
## [b]Lower value[/b] = faster / sharper camera movement.[br]
## [b]Higher value[/b] = slower / heavier camera movement.
@export_custom(PROPERTY_HINT_LINK, "")
var follow_damping_value: Vector2 = Vector2(0.1, 0.1):
	set = set_follow_damping_value,
	get = get_follow_damping_value

## Prevents the [param PhantomCamera2D] from moving in a designated axis.
## This can be enabled or disabled at runtime or from the editor directly.
@export var follow_axis_lock: FollowLockAxis = FollowLockAxis.NONE:
	set = set_lock_axis,
	get = get_lock_axis
var _follow_axis_is_locked: bool = false
var _follow_axis_lock_value: Vector2 = Vector2.ZERO

## Makes the [param PhantomCamera2D] copy the rotation of its [member follow_target][br]
## This behavior is only available when [member follow_mode] is set and only has one [member follow_target].[br][br]
## [b]Important:[/b] Be sure to disable [member Camera2D.ignore_rotation] on the [Camera2D] node to enable this feature.
@export var rotate_with_target: bool = false:
	set = set_rotate_with_target,
	get = get_rotate_with_target
var _should_rotate_with_target: bool = false

## Offsets the rotation when [member rotate_with_target] is enabled.
@export_range(-360.0, 360.0, 0.001, "radians_as_degrees") var rotation_offset: float = 0.0:
	set = set_rotation_offset,
	get = get_rotation_offset

## Enables rotational damping when [member rotate_with_target] is enabled.
@export var rotation_damping: bool = false:
	set = set_rotation_damping,
	get = get_rotation_damping

## Defines the damping amount for the [member rotate_with_target].
@export_range(0.0, 1.0) var rotation_damping_value: float = 0.1:
	set = set_rotation_damping_value,
	get = get_rotation_damping_value

## Enables velocity-based lookahead. As the [param follow target] moves the camera will move further ahead
## based on its velocity. The faster the [param follow target] moves, the further ahead the camera will move.
@export var lookahead: bool = false:
	set = set_lookahead,
	get = get_lookahead

@export_subgroup("Lookahead")
## The amount of [param seconds] to look ahead of the [param follow target]'s position per axis based on
## the [param follow target]'s velocity.[br]
## Each axis has its own prediction time in [param seconds].[br][br]
## A value of [param 0] can be set either to disable lookahead for the corresponding axis.
@export_custom(PROPERTY_HINT_LINK, "suffix:s") var lookahead_time: Vector2 = Vector2(0.5, 0.5):
	set = set_lookahead_time,
	get = get_lookahead_time

## Determines the damping speed of how fast the camera should reach the [member lookahead_time]
## target once the [param follow target] has a positional velocity.[br]
## [b]Lower value[/b] = faster.[br]
## [b]Higher value[/b] = slower.
@export_range(0.0, 1.0, 0.001, "or_greater") var lookahead_acceleration: float = 0.2:
	set = set_lookahead_acceleration,
	get = get_lookahead_acceleration

## Determines the damping speed of how fast the camera should decelerate back to the
## [param follow target]'s position once it has no positional velocity.[br]
## [b]Lower value[/b] = faster.[br]
## [b]Higher value[/b] = slower.
@export_range(0.0, 1.0, 0.001, "or_greater") var lookahead_deceleration: float = 0.2:
	set = set_lookahead_deceleration,
	get = get_lookahead_deceleration

## Enables a maximum velocity limit in [param pixels per second] for the [member follow_lookahead] effect.[br]
## If [code]true[/code], the [param follow target's] velocity will be clamped to the [member follow_lookahead_max_value] before calculating lookahead.[br]
## In other words, no matter how fast the target's actual velocity is, the lookahead will only follow up to the speed defined here.
@export var lookahead_max: bool = false:
	set = set_lookahead_max,
	get = get_lookahead_max

## The maximum [member lookahead] velocity in [param pixels per second].
## The [param follow target]'s velocity will be clamped within these bounds on each axis before applying lookahead time.
@export_custom(PROPERTY_HINT_LINK, "suffix:px/s") var lookahead_max_value: Vector2 = Vector2(200.0, 200.0):
	set = set_lookahead_max_value,
	get = get_lookahead_max_value


@export_subgroup("Follow Group")
## Enables the [param PhantomCamera2D] to dynamically zoom in and out based on
## the targets' distances between each other.
## Once enabled, the [param Camera2D] will stay as zoomed in as possible,
## limited by the [member auto_zoom_max] and start zooming out as the targets
## move further apart, limited by the [member auto_zoom_min].
## Note: Enabling this property hides and disables the [member zoom] property
## as this effectively overrides that value.
@export var auto_zoom: bool = false:
	set = set_auto_zoom,
	get = get_auto_zoom

## Sets the param minimum zoom amount, in other words how far away the
## [param Camera2D] can be from scene.[br][br]
## This only works when [member auto_zoom] is enabled.
@export var auto_zoom_min: float = 1.0:
	set = set_auto_zoom_min,
	get = get_auto_zoom_min

## Sets the maximum zoom amount, in other words how close the [param Camera2D]
## can move towards the scene.[br][br]
## This only works when [member auto_zoom] is enabled.
@export var auto_zoom_max: float = 5.0:
	set = set_auto_zoom_max,
	get = get_auto_zoom_max

## Determines how close to the edges the targets are allowed to be.
## This is useful to avoid targets being cut off at the edges of the screen.
## [br][br]
## The Vector4 parameter order goes: [param Left] - [param Top] - [param Right]
## - [param Bottom].
@export var auto_zoom_margin: Vector4 = Vector4.ZERO:
	set = set_auto_zoom_margin,
	get = get_auto_zoom_margin


@export_subgroup("Dead Zones")
## Defines the horizontal dead zone area. While the target is within it, the
## [param PhantomCamera2D] will not move in the horizontal axis.
## If the targeted node leaves the horizontal bounds, the
## [param PhantomCamera2D] will follow the target horizontally to keep
## it within bounds.
@export_range(0.0, 1.0) var dead_zone_width: float = 0.0:
	set(value):
		dead_zone_width = value
		dead_zone_changed.emit()
	get:
		return dead_zone_width

## Defines the vertical dead zone area. While the target is within it, the
## [param PhantomCamera2D] will not move in the vertical axis.
## If the targeted node leaves the vertical bounds, the
## [param PhantomCamera2D] will follow the target horizontally to keep
## it within bounds.
@export_range(0.0, 1.0) var dead_zone_height: float = 0.0:
	set(value):
		dead_zone_height = value
		dead_zone_changed.emit()
	get:
		return dead_zone_height

## Enables the [param dead zones] to be visible when running the game from the editor.
## [br]
## [param dead zones] will never be visible in build exports.
@export var show_viewfinder_in_play: bool = false


@export_group("Limit")
## Shows the [param Camera2D]'s built-in limit border.[br]
## The [param PhantomCamera2D] and [param Camera2D] can move around anywhere within it.
@export var draw_limits: bool = false:
	set(value):
		_draw_limits = value
		if Engine.is_editor_hint():
			_draw_camera_2d_limit()
	get:
		return _draw_limits

## Defines the left side of the [param Camera2D] limit.
## The camera will not be able to move past this point.
@export var limit_left: int = -10000000:
	set = set_limit_left,
	get = get_limit_left
## Defines the top side of the [param Camera2D] limit.
## The camera will not be able to move past this point.
@export var limit_top: int = -10000000:
	set = set_limit_top,
	get = get_limit_top
## Defines the right side of the [param Camera2D] limit.
## The camera will not be able to move past this point.
@export var limit_right: int = 10000000:
	set = set_limit_right,
	get = get_limit_right
## Defines the bottom side of the [param Camera2D] limit.
## The camera will not be able to move past this point.
@export var limit_bottom: int = 10000000:
	set = set_limit_bottom,
	get = get_limit_bottom

## Allows for setting either a [TileMapLayer] or [CollisionShape2D] node to
## automatically apply a limit size instead of manually adjusting the Left,
## Top, Right and Left properties.[br][br]
## [b]TileMapLayer[/b][br]
## The Limit will update after the [TileSet] of the [TileMapLayer] has changed.[br]
## [b]Note:[/b] The limit size will only update after closing the TileMap editor
## bottom panel.
## [br][br]
## [b]CollisionShape2D[/b][br]
## The limit will update in realtime as the Shape2D changes its size.
## Note: For performance reasons, resizing the [Shape2D] during runtime will not change the Limits sides.
@export_node_path("TileMapLayer", "CollisionShape2D") var limit_target: NodePath = NodePath(""):
	set = set_limit_target,
	get = get_limit_target

## Applies an offset to the [TileMapLayer] Limit or [Shape2D] Limit.
## The values goes from [param Left], [param Top], [param Right]
## and [param Bottom].
@export var limit_margin: Vector4i = Vector4i.ZERO:
	set = set_limit_margin,
	get = get_limit_margin
#@export var limit_smoothed: bool = false: # TODO - Needs proper support
	#set = set_limit_smoothing,
	#get = get_limit_smoothing

@export_group("Noise")
## Applies a noise, or shake, to a [Camera2D].[br]
## Once set, the noise will run continuously after the tween to the [PhantomCamera2D] is complete.
@export var noise: PhantomCameraNoise2D = null:
	set = set_noise,
	get = get_noise

## If true, will trigger the noise while in the editor.[br]
## Useful in cases where you want to temporarily disable the noise in the editor without removing
## the resource.[br][br]
## [b]Note:[/b] This property has no effect on runtime behaviour.
@export var _preview_noise: bool = true:
	set(value):
		_preview_noise = value
		if not value:
			_transform_noise = Transform2D()

## Enable a corresponding layer for a [member PhantomCameraNoiseEmitter2D.noise_emitter_layer]
## to make this [PhantomCamera2D] be affect by it.
@export_flags_2d_render var noise_emitter_layer: int = 0:
	set = set_noise_emitter_layer,
	get = get_noise_emitter_layer

#region Private Variables

var _is_active: bool = false

var _should_follow: bool = false
var _follow_target_physics_based: bool = false
var _physics_interpolation_enabled: bool = false # NOTE - Enable for Godot 4.3 and when PhysicsInterpolationMode bug is resolved

var _follow_target_physics_class: FollowTargetPhysicsClass = FollowTargetPhysicsClass.OTHER
var _character_body_2d: CharacterBody2D = null
var _rigid_body_2d: RigidBody2D = null

var _has_multiple_follow_targets: bool = false
var _follow_targets_single_target_index: int = 0
var _follow_targets: Array[Node2D] = []

var _follow_velocity_ref: Vector2 = Vector2.ZERO # Stores and applies the velocity of the follow movement
var _rotation_velocity_ref: float = 0.0 # Stores and applies the velocity of the rotation movement

var _has_follow_path: bool = false

var _has_lookahead_acceleration: bool = true
var _has_lookahead_deceleration: bool = true

var _tween_skip: bool = false

## Defines the position of the [member follow_target] within the viewport.[br]
## This is only used for when [member follow_mode] is set to [param Framed].
var _follow_framed_initial_set: bool = false

var _lookahead_offset: Vector2 = Vector2.ZERO
var _lookahead_offset_velocity_ref: Vector2 = Vector2.ZERO

var _lookahead_sample_pos_prev: Vector2 = Vector2.ZERO
var _lookahead_has_prev_sample: bool = false


static var _draw_limits: bool = false

var _limit_sides: Vector4i = _limit_sides_default
var _limit_sides_default: Vector4i = Vector4i(-10000000, -10000000, 10000000, 10000000)

var _limit_node: Node2D = null
var _tile_size_perspective_scaler: Vector2 = Vector2.ONE

var _limit_inactive_pcam: bool = false

var _follow_target_position: Vector2 = Vector2.ZERO

var _transform_output: Transform2D = Transform2D()
var _transform_noise: Transform2D = Transform2D()

var _has_noise_resource: bool = false

# NOTE - Temp solution until Godot has better plugin autoload recognition out-of-the-box.
var _phantom_camera_manager: Node = null

#endregion

#region Public Variables

var tween_duration: float:
	set = set_tween_duration,
	get = get_tween_duration
var tween_transition: PhantomCameraTween.TransitionType:
	set = set_tween_transition,
	get = get_tween_transition
var tween_ease: PhantomCameraTween.EaseType:
	set = set_tween_ease,
	get = get_tween_ease

var viewport_position: Vector2

#endregion

#region Private Functions

func _validate_property(property: Dictionary) -> void:
	################
	## Follow Target
	################
	if property.name == "follow_target":
		if follow_mode == FollowMode.NONE or \
		follow_mode == FollowMode.GROUP:
			property.usage = PROPERTY_USAGE_NO_EDITOR

	elif property.name == "follow_path" and \
	follow_mode != FollowMode.PATH:
		property.usage = PROPERTY_USAGE_NO_EDITOR


	####################
	## Follow Parameters
	####################
	if follow_mode == FollowMode.NONE:
		match property.name:
			"follow_offset", \
			"follow_damping", \
			"follow_damping_value", \
			"follow_axis_lock", \
			"rotate_with_target", \
			"lookahead":
				property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "follow_offset":
		if follow_mode == FollowMode.GLUED:
			property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "follow_damping_value" and not follow_damping:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	###############
	## Follow Group
	###############
	if follow_mode != FollowMode.GROUP:
		match property.name:
			"follow_targets", \
			"auto_zoom":
				property.usage = PROPERTY_USAGE_NO_EDITOR

	if not auto_zoom or follow_mode != FollowMode.GROUP:
		match property.name:
			"auto_zoom_min", \
			"auto_zoom_max", \
			"auto_zoom_margin":
				property.usage = PROPERTY_USAGE_NO_EDITOR

	################
	## Follow Framed
	################
	if not follow_mode == FollowMode.FRAMED:
		match property.name:
			"dead_zone_width", \
			"dead_zone_height", \
			"show_viewfinder_in_play":
				property.usage = PROPERTY_USAGE_NO_EDITOR


	###############
	## Look Ahead
	###############
	# Look-ahead only available for single-target follow modes
	if not lookahead:
		match property.name:
			"lookahead_time", \
			"lookahead_max", \
			"lookahead_max_value", \
			"lookahead_acceleration", \
			"lookahead_deceleration":
				property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "lookahead_max_value" and not lookahead_max:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	#####################
	## Rotate With Target
	#####################
	if property.name == "rotate_with_target" and follow_mode == FollowMode.GROUP:
		property.usage = PROPERTY_USAGE_NO_EDITOR


	if not rotate_with_target or follow_mode == FollowMode.GROUP:
		match property.name:
			"rotation_damping", \
			"rotation_offset", \
			"rotation_damping_value":
				property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "rotation_damping_value":
		if not rotation_damping:
			property.usage = PROPERTY_USAGE_NO_EDITOR


	#######
	## Zoom
	#######
	if property.name == "zoom" and follow_mode == FollowMode.GROUP and auto_zoom:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	########
	## Limit
	########
	if is_instance_valid(_limit_node):
		match property.name:
			"limit_left", \
			"limit_top", \
			"limit_right", \
			"limit_bottom":
				property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "limit_margin" and not _limit_node:
		property.usage = PROPERTY_USAGE_NO_EDITOR


func _enter_tree() -> void:
	_phantom_camera_manager = Engine.get_singleton(_constants.PCAM_MANAGER_NODE_NAME)
	_tween_skip = !tween_on_load

	_phantom_camera_manager.pcam_added(self)

	priority_override = false

	match follow_mode:
		FollowMode.NONE:
			_is_parents_physics()
		FollowMode.PATH:
			if is_instance_valid(follow_path):
				_should_follow_checker()
			else:
				_should_follow = false
		FollowMode.GROUP:
			_follow_targets_size_check()
		_:
			_should_follow_checker()

	if not visibility_changed.is_connected(_check_visibility):
		visibility_changed.connect(_check_visibility)

	update_limit_all_sides()


func _exit_tree() -> void:
	if not follow_mode == FollowMode.GROUP:
		follow_targets = []

	if not is_instance_valid(_phantom_camera_manager): return
	_phantom_camera_manager.pcam_removed(self)


func _ready() -> void:
	_transform_output = global_transform

	_phantom_camera_manager.noise_2d_emitted.connect(_noise_emitted)

	if not Engine.is_editor_hint():
		_preview_noise = true


func _process(delta: float) -> void:
	if _follow_target_physics_based or _is_active: return
	process_logic(delta)


func _physics_process(delta: float) -> void:
	if not _follow_target_physics_based or _is_active: return
	process_logic(delta)


func process_logic(delta: float) -> void:
	if _is_active:
		if _has_noise_resource and _preview_noise:
			_transform_noise = noise.get_noise_transform(delta)
	else:
		match inactive_update_mode:
			InactiveUpdateMode.NEVER: return
			InactiveUpdateMode.ALWAYS:
				# Only triggers if limit isn't default
				if _limit_inactive_pcam:
					global_position = _set_limit_clamp_position(global_position)
			# InactiveUpdateMode.EXPONENTIALLY:
			# TODO - Trigger positional updates less frequently as more PCams gets added

	_limit_checker()

	if _should_follow:
		_follow(delta)
	else:
		_transform_output = global_transform

	if _follow_axis_is_locked:
		match follow_axis_lock:
			FollowLockAxis.X:
				_transform_output.origin.x = _follow_axis_lock_value.x
			FollowLockAxis.Y:
				_transform_output.origin.y = _follow_axis_lock_value.y
			FollowLockAxis.XY:
				_transform_output.origin.x = _follow_axis_lock_value.x
				_transform_output.origin.y = _follow_axis_lock_value.y


func _limit_checker() -> void:
	## TODO - Needs to see if this can be triggerd only from CollisionShape2D Transform changes
	if not Engine.is_editor_hint(): return
	if draw_limits:
		update_limit_all_sides()


func _follow(delta: float) -> void:
	_set_follow_position(delta)
	_interpolate_position(_follow_target_position, delta)


func _set_follow_position(delta: float) -> void:
	match follow_mode:
		FollowMode.GLUED:
			_follow_target_position = follow_target.global_position
			if lookahead and not Engine.is_editor_hint():
				_follow_target_position = _apply_lookahead(_follow_target_position, delta)

		FollowMode.SIMPLE:
			_follow_target_position = _get_target_position_offset()
			if lookahead and not Engine.is_editor_hint():
				_follow_target_position = _apply_lookahead(_follow_target_position, delta)

		FollowMode.GROUP:
			if _has_multiple_follow_targets:
				var rect: Rect2 = Rect2(_follow_targets[0].global_position, Vector2.ZERO)
				for target in _follow_targets:
					rect = rect.expand(target.global_position)
				if auto_zoom:
					rect = rect.grow_individual(
						auto_zoom_margin.x,
						auto_zoom_margin.y,
						auto_zoom_margin.z,
						auto_zoom_margin.w
					)

					if rect.size.x > rect.size.y * _phantom_camera_manager.screen_size.aspect():
						zoom = clamp(_phantom_camera_manager.screen_size.x / rect.size.x, auto_zoom_min, auto_zoom_max) * Vector2.ONE
					else:
						zoom = clamp(_phantom_camera_manager.screen_size.y / rect.size.y, auto_zoom_min, auto_zoom_max) * Vector2.ONE

				var target_position: Vector2 = rect.get_center() + follow_offset
				if lookahead and not Engine.is_editor_hint():
					target_position = _apply_lookahead(target_position, delta)

				_follow_target_position = target_position
			else:
				_follow_target_position = follow_targets[_follow_targets_single_target_index].global_position + follow_offset

		FollowMode.PATH:
			var path_position: Vector2 = follow_path.global_position
			var follow_postion: Vector2 = _get_target_position_offset()

			if lookahead and not Engine.is_editor_hint():
				follow_postion = _apply_lookahead(follow_postion, delta)

			_follow_target_position = \
			follow_path.curve.get_closest_point(
				follow_postion - path_position
			) + path_position

		FollowMode.FRAMED:
			if Engine.is_editor_hint() or not _is_active:
				_follow_target_position = _get_target_position_offset()
			else:
				var target_position: Vector2 = _get_target_position_offset()
				var viewport_rect: Vector2 = get_viewport_rect().size
				if lookahead and not Engine.is_editor_hint():
					target_position = _apply_lookahead(target_position, delta)

				var viewport_dead_zone: Vector4 = Vector4(
					viewport_rect.x / 2 / zoom.x * dead_zone_width,     # Left ## TODO - Replace with specific left dead zone value
					viewport_rect.y / 2 / zoom.y * dead_zone_height,    # Top ## TODO - Replace with specific top dead zone value
					viewport_rect.x / 2 / zoom.x * dead_zone_width,     # Right ## TODO - Replace with specific right dead zone value
					viewport_rect.y / 2 / zoom.y * dead_zone_height,    # Bottom  ## TODO - Replace with specific bottom dead zone value
				)

				var viewport_target_offset: Vector2 = Vector2.ZERO
				var dead_zone_side_reached: Vector2i = Vector2i.ZERO

				var left_dead_zone: float = global_position.x - viewport_dead_zone.x
				var right_dead_zone: float = global_position.x + viewport_dead_zone.z
				## Left Dead Zone
				if left_dead_zone > target_position.x:
					viewport_target_offset.x = left_dead_zone - target_position.x
					_follow_target_position.x -= viewport_target_offset.x
					dead_zone_side_reached.x = 1
				## Right Dead Zone
				elif right_dead_zone < target_position.x:
					viewport_target_offset.x = right_dead_zone - target_position.x
					_follow_target_position.x -= viewport_target_offset.x
					dead_zone_side_reached.x = -1

				var top_dead_zone: float = global_position.y - viewport_dead_zone.y
				var bottom_dead_zone: float = global_position.y + viewport_dead_zone.w
				## Top Dead Zone
				if top_dead_zone > target_position.y:
					viewport_target_offset.y = top_dead_zone - target_position.y
					_follow_target_position.y -= viewport_target_offset.y
					dead_zone_side_reached.y = 1
				## Bottom Dead Zone
				elif bottom_dead_zone < target_position.y:
					viewport_target_offset.y = bottom_dead_zone - target_position.y
					_follow_target_position.y -= viewport_target_offset.y
					dead_zone_side_reached.y = -1

				if dead_zone_side_reached != Vector2i.ZERO:
					dead_zone_reached.emit(dead_zone_side_reached)

				if show_viewfinder_in_play:
					var target_screen_position: Vector2 = Transform2D(get_viewport().canvas_transform * Transform2D(0, target_position + viewport_target_offset)).origin
					viewport_position = target_screen_position / viewport_rect
		_: pass

func _set_follow_velocity(index: int, value: float):
	_follow_velocity_ref[index] = value

func _set_rotation_velocity(index: int, value: float):
	_rotation_velocity_ref = value


func _reset_lookahead() -> void:
	_lookahead_offset = Vector2.ZERO
	_lookahead_offset_velocity_ref = Vector2.ZERO
	_lookahead_has_prev_sample = false


func _set_lookahead_velocity(index: int, value: float) -> void:
	_lookahead_offset_velocity_ref[index] = value


func _get_follow_target_velocity(target_position: Vector2, delta: float) -> Vector2:
	match _follow_target_physics_class:
		FollowTargetPhysicsClass.CHARACTERBODY:
			return _character_body_2d.velocity
		FollowTargetPhysicsClass.RIGIDBODY:
			return _rigid_body_2d.linear_velocity
		FollowTargetPhysicsClass.OTHER:
			if follow_mode != FollowMode.GROUP:
				if follow_target.has_method(&"get_velocity"):
					var v = follow_target.call(&"get_velocity")
					if v is Vector2:
						return v

				var prop_v = follow_target.get(&"velocity")
				if prop_v is Vector2:
					return prop_v

	if not _lookahead_has_prev_sample:
		_lookahead_has_prev_sample = true
		_lookahead_sample_pos_prev = target_position
		return Vector2.ZERO

	var current_position: Vector2
	if follow_mode == FollowMode.GROUP:
		if _has_multiple_follow_targets:
			current_position = target_position
		else:
			current_position = follow_targets[_follow_targets_single_target_index].global_position + follow_offset
	else:
		current_position = _get_target_position_offset()

	if not _lookahead_has_prev_sample:
		_lookahead_has_prev_sample = true
		_lookahead_sample_pos_prev = current_position
		return Vector2.ZERO

	var velocity: Vector2 = (current_position - _lookahead_sample_pos_prev) / maxf(delta, 0.0001)
	_lookahead_sample_pos_prev = current_position

	return velocity


func _apply_lookahead(target_position: Vector2, delta: float) -> Vector2:
	var velocity: Vector2 = _get_follow_target_velocity(target_position, delta)

	if lookahead_max:
		velocity = Vector2(
			clampf(velocity.x, -lookahead_max_value.x, lookahead_max_value.x),
			clampf(velocity.y, -lookahead_max_value.y, lookahead_max_value.y),
		)

	var desired: Vector2 = velocity * lookahead_time
	for i in 2:
		# Determine if moving toward desired (accelerating) or away from it (decelerating)
		var is_accelerating: bool = signf(desired[i] - _lookahead_offset[i]) == signf(desired[i])
		var smooth_time: float
		var lookahead_is_smooth: bool

		if is_accelerating:
			lookahead_is_smooth = _has_lookahead_acceleration
			smooth_time = lookahead_acceleration
		else:
			lookahead_is_smooth = _has_lookahead_deceleration
			smooth_time = lookahead_deceleration

		if lookahead_is_smooth:
			_lookahead_offset[i] = _smooth_damp(
				desired[i],
				_lookahead_offset[i],
				i,
				_lookahead_offset_velocity_ref[i],
				_set_lookahead_velocity,
				smooth_time,
				delta
			)
		else:
			_lookahead_offset[i] = desired[i]

	return target_position + _lookahead_offset


func _interpolate_position(target_position: Vector2, delta: float) -> void:
	var output_rotation: float = global_transform.get_rotation()
	if rotate_with_target:
		if rotation_damping and not Engine.is_editor_hint():
			output_rotation = _smooth_damp(
				follow_target.get_rotation() + rotation_offset,
				_transform_output.get_rotation(),
				0,
				_rotation_velocity_ref,
				_set_rotation_velocity,
				rotation_damping_value,
				delta
			)
		else:
			output_rotation = follow_target.get_rotation() + rotation_offset

	## Applies the raw target position to the PCam2D
	global_position = target_position

	## Applies Damping to the Transform2D output
	if not Engine.is_editor_hint():
		if follow_damping:
			for i in 2:
				target_position[i] = _smooth_damp(
					global_position[i],
					_transform_output.origin[i],
					i,
					_follow_velocity_ref[i],
					_set_follow_velocity,
					follow_damping_value[i],
					delta
				)

	if _limit_inactive_pcam and not _tween_skip:
		target_position = _set_limit_clamp_position(target_position)

	_transform_output = Transform2D(output_rotation, target_position)


func _smooth_damp(target_axis: float, self_axis: float, index: int, current_velocity: float, set_velocity: Callable, damping_time: float, delta: float) -> float:
	damping_time = maxf(0.0001, damping_time)
	var omega: float = 2 / damping_time
	var x: float = omega * delta
	var exponential: float = 1 / (1 + x + 0.48 * x * x + 0.235 * x * x * x)
	var diff: float = self_axis - target_axis
	var _target_axis: float = target_axis

	var max_change: float = INF * damping_time
	diff = clampf(diff, -max_change, max_change)
	target_axis = self_axis - diff

	var temp: float = (current_velocity + omega * diff) * delta
	set_velocity.call(index, (current_velocity - omega * temp) * exponential)
	var output: float = target_axis + (diff + temp) * exponential

	## To prevent overshooting
	if (_target_axis - self_axis > 0.0) == (output > _target_axis):
		output = _target_axis
		set_velocity.call(index, (output - _target_axis) / delta)

	return output


func _set_limit_clamp_position(value: Vector2) -> Vector2:
	var camera_frame_rect_size: Vector2 = _camera_frame_rect().size
	value.x = clampf(value.x, _limit_sides.x + camera_frame_rect_size.x / 2, _limit_sides.z - camera_frame_rect_size.x / 2)
	value.y = clampf(value.y, _limit_sides.y + camera_frame_rect_size.y / 2, _limit_sides.w - camera_frame_rect_size.y / 2)
	return value


func _draw() -> void:
	if not Engine.is_editor_hint(): return

	if frame_preview and not _is_active:
		draw_rect(_camera_frame_rect(), Color("3ab99a"), false, 2)


func _camera_frame_rect() -> Rect2:
	var screen_size_zoom: Vector2 = Vector2(_phantom_camera_manager.screen_size.x / get_zoom().x, _phantom_camera_manager.screen_size.y / get_zoom().y)

	return Rect2(-screen_size_zoom / 2, screen_size_zoom)


func _on_tile_map_changed() -> void:
	update_limit_all_sides()


func _get_target_position_offset() -> Vector2:
	return follow_target.global_position + follow_offset


func _on_dead_zone_changed() -> void:
	global_position = _get_target_position_offset()


func _draw_camera_2d_limit() -> void:
	if not is_instance_valid(_phantom_camera_manager): return
	_phantom_camera_manager.draw_limit_2d.emit(draw_limits)


func _check_limit_is_not_default() -> void:
	if _limit_sides == _limit_sides_default:
		_limit_inactive_pcam = false
	else:
		_limit_inactive_pcam = true


func _check_visibility() -> void:
	_phantom_camera_manager.pcam_visibility_changed.emit(self)


func _follow_target_tree_exiting(target: Node) -> void:
	if target == follow_target:
		_should_follow = false
	if _follow_targets.has(target):
		_follow_targets.erase(target)


func _should_follow_checker() -> void:
	if follow_mode == FollowMode.NONE:
		_should_follow = false
		return

	if not follow_mode == FollowMode.GROUP:
		if is_instance_valid(follow_target):
			_should_follow = true
		else:
			_should_follow = false


func _follow_targets_size_check() -> void:
	var targets_size: int = 0
	_follow_target_physics_based = false
	_follow_targets = []
	for i in follow_targets.size():
		if follow_targets[i] == null: continue
		if is_instance_valid(follow_targets[i]):
			_follow_targets.append(follow_targets[i])
			targets_size += 1
			_follow_targets_single_target_index = i
			_check_physics_body(follow_targets[i])
			if not follow_targets[i].tree_exiting.is_connected(_follow_target_tree_exiting):
				follow_targets[i].tree_exiting.connect(_follow_target_tree_exiting.bind(follow_targets[i]))

	match targets_size:
		0:
			_should_follow = false
			_has_multiple_follow_targets = false
		1:
			_should_follow = true
			_has_multiple_follow_targets = false
		_:
			_should_follow = true
			_has_multiple_follow_targets = true


func _noise_emitted(emitter_noise_output: Transform2D, emitter_layer: int) -> void:
	if noise_emitter_layer & emitter_layer != 0:
		noise_emitted.emit(emitter_noise_output)


func _set_layer(current_layers: int, layer_number: int, value: bool) -> int:
	var mask: int = current_layers

	# From https://github.com/godotengine/godot/blob/51991e20143a39e9ef0107163eaf283ca0a761ea/scene/3d/camera_3d.cpp#L638
	if layer_number < 1 or layer_number > 20:
		printerr("Render layer must be between 1 and 20.")
	else:
		if value:
			mask |= 1 << (layer_number - 1)
		else:
			mask &= ~(1 << (layer_number - 1))

	return mask


func _check_physics_body(target: Node2D) -> void:
	# Reset cached physics references
	_character_body_2d = null
	_rigid_body_2d = null
	_follow_target_physics_class = FollowTargetPhysicsClass.OTHER

	if target is PhysicsBody2D:
		# Cache the type and reference for performance
		if target is CharacterBody2D:
			_character_body_2d = target as CharacterBody2D
			_follow_target_physics_class = FollowTargetPhysicsClass.CHARACTERBODY
		elif target is RigidBody2D:
			_rigid_body_2d = target as RigidBody2D
			_follow_target_physics_class = FollowTargetPhysicsClass.RIGIDBODY

		var show_jitter_tips := ProjectSettings.get_setting("phantom_camera/tips/show_jitter_tips")
		var physics_interpolation_enabled := ProjectSettings.get_setting("physics/common/physics_interpolation")

		## NOTE - Feature Toggle
		if not physics_interpolation_enabled and _follow_target_physics_based and show_jitter_tips == null:
			printerr("Physics Interpolation is disabled in the Project Settings, recommend enabling it to smooth out physics-based camera movement")
			print_rich("This tip can be disabled from within [code]Project Settings / Phantom Camera / Tips / Show Jitter Tips[/code]")
		_follow_target_physics_based = true
	else:
		_is_parents_physics(target)
	physics_target_changed.emit()


func _is_parents_physics(target: Node = self) -> void:
	var current_node: Node = target
	while current_node:
		current_node = current_node.get_parent()
		if not current_node is PhysicsBody2D: continue
		_follow_target_physics_based = true

#endregion


#region Public Functions

## Updates the limit sides based what has been set to define it
## This should be automatic, but can be called manully if need be.
func update_limit_all_sides() -> void:
	var limit_rect: Rect2

	if not is_instance_valid(_limit_node):
		_limit_sides.x = limit_left
		_limit_sides.y = limit_top
		_limit_sides.z = limit_right
		_limit_sides.w = limit_bottom
	elif _limit_node is TileMapLayer:
		var tile_map: TileMapLayer = _limit_node

		if not tile_map.tile_set: return # TODO: This should be removed once https://github.com/godotengine/godot/issues/96898 is resolved

		var tile_map_size: Vector2 = Vector2(tile_map.get_used_rect().size) * Vector2(tile_map.tile_set.tile_size) * tile_map.get_scale()
		var tile_map_position: Vector2 = tile_map.global_position + Vector2(tile_map.get_used_rect().position) * Vector2(tile_map.tile_set.tile_size) * tile_map.get_scale()

		## Calculates the Rect2 based on the Tile Map position and size + margin
		limit_rect = Rect2(
			tile_map_position + Vector2(limit_margin.x, limit_margin.y),
			tile_map_size - Vector2(limit_margin.x, limit_margin.y) - Vector2(limit_margin.z, limit_margin.w)
		)

		# Left
		_limit_sides.x = roundi(limit_rect.position.x)
		# Top
		_limit_sides.y = roundi(limit_rect.position.y)
		# Right
		_limit_sides.z = roundi(limit_rect.position.x + limit_rect.size.x)
		# Bottom
		_limit_sides.w = roundi(limit_rect.position.y + limit_rect.size.y)
	elif _limit_node is CollisionShape2D:
		var collision_shape_2d: CollisionShape2D = _limit_node as CollisionShape2D

		if not collision_shape_2d.get_shape(): return

		var shape_2d: Shape2D = collision_shape_2d.get_shape()
		var shape_2d_size: Vector2 = shape_2d.get_rect().size
		var shape_2d_position: Vector2 = collision_shape_2d.global_position + Vector2(shape_2d.get_rect().position)

		## Calculates the Rect2 based on the Tile Map position and size
		limit_rect = Rect2(shape_2d_position, shape_2d_size)

		## Calculates the Rect2 based on the Tile Map position and size + margin
		limit_rect = Rect2(
			limit_rect.position + Vector2(limit_margin.x, limit_margin.y),
			limit_rect.size - Vector2(limit_margin.x, limit_margin.y) - Vector2(limit_margin.z, limit_margin.w)
		)

		# Left
		_limit_sides.x = roundi(limit_rect.position.x)
		# Top
		_limit_sides.y = roundi(limit_rect.position.y)
		# Right
		_limit_sides.z = roundi(limit_rect.position.x + limit_rect.size.x)
		# Bottom
		_limit_sides.w = roundi(limit_rect.position.y + limit_rect.size.y)

	_check_limit_is_not_default()
	if not _is_active: return
	if not is_instance_valid(_phantom_camera_manager): return
	_phantom_camera_manager.limit_2d_changed.emit(SIDE_LEFT, _limit_sides.x)
	_phantom_camera_manager.limit_2d_changed.emit(SIDE_TOP, _limit_sides.y)
	_phantom_camera_manager.limit_2d_changed.emit(SIDE_RIGHT, _limit_sides.z)
	_phantom_camera_manager.limit_2d_changed.emit(SIDE_BOTTOM, _limit_sides.w)
	_phantom_camera_manager.draw_limit_2d.emit(draw_limits)


func reset_limit() -> void:
	if not is_instance_valid(_phantom_camera_manager): return
	_phantom_camera_manager.limit_2d_changed.emit(SIDE_LEFT, _limit_sides_default.x)
	_phantom_camera_manager.limit_2d_changed.emit(SIDE_TOP, _limit_sides_default.y)
	_phantom_camera_manager.limit_2d_changed.emit(SIDE_RIGHT, _limit_sides_default.z)
	_phantom_camera_manager.limit_2d_changed.emit(SIDE_BOTTOM, _limit_sides_default.w)
	_phantom_camera_manager.draw_limit_2d.emit(draw_limits)


## Assigns the value of the [param has_tweened] property.
## [b][color=yellow]Important:[/color][/b] This value can only be changed
## from the [PhantomCameraHost] script.
func set_tween_skip(caller: Node, value: bool) -> void:
	if is_instance_of(caller, PhantomCameraHost):
		_tween_skip = value
	else:
		printerr("Can only be called PhantomCameraHost class")
## Returns the current [param has_tweened] value.
func get_tween_skip() -> bool:
	return _tween_skip

## Returns the [Transform3D] value based on the [member follow_mode] / [member look_at_mode] target value.
func get_transform_output() -> Transform2D:
	return _transform_output


## Returns the noise [Transform3D] value.
func get_noise_transform() -> Transform2D:
	return _transform_noise


## Emits a noise based on a custom [Transform2D] value.[br]
## Use this function if you wish to make use of external noise patterns from, for example, other addons.
func emit_noise(value: Transform2D) -> void:
	noise_emitted.emit(value)


## Teleports the [param PhantomCamera2D] and [Camera2D] to their designated position,
## bypassing the damping process.
func teleport_position() -> void:
	_follow_velocity_ref = Vector2.ZERO
	_reset_lookahead()
	_set_follow_position(0.0)
	_transform_output.origin = _follow_target_position
	_phantom_camera_manager.pcam_teleport.emit(self)


# TODO: Enum link does link to anywhere is being tracked in: https://github.com/godotengine/godot/issues/106828
## Returns true if this [param PhantomCamera2D]'s [member follow_mode] is not set to [enum FollowMode]
## and has a valid [member follow_target].
func is_following() -> bool:
	return _should_follow

#endregion


#region Setter & Getter Functions

## Assigns new [member zoom] value.
func set_zoom(value: Vector2) -> void:
	zoom = value
	queue_redraw()

## Gets current [member zoom] value.
func get_zoom() -> Vector2:
	return zoom


## Assigns new [member priority] value.
func set_priority(value: int) -> void:
	priority = maxi(0, value)
	if not is_node_ready(): return
	if not Engine.has_singleton(_constants.PCAM_MANAGER_NODE_NAME): return
	Engine.get_singleton(_constants.PCAM_MANAGER_NODE_NAME).pcam_priority_changed.emit(self)

## Gets current [member priority] value.
func get_priority() -> int:
	return priority


## Assigns a new PhantomCameraTween resource to the PhantomCamera2D
func set_tween_resource(value: PhantomCameraTween) -> void:
	tween_resource = value

## Gets the PhantomCameraTween resource assigned to the PhantomCamera2D
## Returns null if there's nothing assigned to it.
func get_tween_resource() -> PhantomCameraTween:
	return tween_resource


## Assigns a new [param Tween Duration] to the [member tween_resource] value.[br]
## The duration value is in seconds.
func set_tween_duration(value: float) -> void:
	tween_resource.duration = value

## Gets the current [param Tween Duration] value inside the
## [member tween_resource].[br]
## The duration value is in seconds.
func get_tween_duration() -> float:
	if tween_resource:
		return tween_resource.duration
	else:
		return 0.0 # Makes tween instant


## Assigns a new [param Tween Transition] value inside the
## [member tween_resource].
func set_tween_transition(value: int) -> void:
	tween_resource.transition = value

## Gets the current [param Tween Transition] value  inside the
## [member tween_resource].
func get_tween_transition() -> int:
	if tween_resource:
		return tween_resource.transition
	else:
		return 0 # Equals TransitionType.LINEAR


## Assigns a new [param Tween Ease] value inside the [member tween_resource].
func set_tween_ease(value: int) -> void:
	tween_resource.ease = value

## Gets the current [param Tween Ease] value inside the [member tween_resource].
func get_tween_ease() -> int:
	if tween_resource:
		return tween_resource.ease
	else:
		return 2 # Equals EaseType.EASE_IN_OUT


## Sets the [param PhantomCamera2D] active state.[br]
## [b][color=yellow]Important:[/color][/b] This value can only be changed
## from the [PhantomCameraHost] script.
func set_is_active(node, value) -> void:
	if node is PhantomCameraHost:
		_is_active = value
		queue_redraw()
	else:
		printerr("PCams can only be set from the PhantomCameraHost")

## Gets current active state of the [param PhantomCamera2D].
## If it returns true, it means the [param PhantomCamera2D] is what the
## [param Camera2D] is currently following.
func is_active() -> bool:
	return _is_active


## Enables or disables the [member tween_on_load].
func set_tween_on_load(value: bool) -> void:
	tween_on_load = value

## Gets the current [member tween_on_load] value.
func get_tween_on_load() -> bool:
	return tween_on_load

## Sets the [member host_layers] value.
func set_host_layers(value: int) -> void:
	host_layers = value
	if is_instance_valid(_phantom_camera_manager):
		_phantom_camera_manager.pcam_host_layer_changed.emit(self)

## Enables or disables a given layer of [member host_layers].
func set_host_layers_value(layer: int, value: bool) -> void:
	host_layers = _set_layer(host_layers, layer, value)

## Gets the current [member host_layers].
func get_host_layers() -> int:
	return host_layers


## Gets the current follow mode as an enum int based on [enum FollowMode].[br]
## [b]Note:[/b] Setting [enum FollowMode] purposely not added.
## A separate PCam should be used instead.
func get_follow_mode() -> int:
	return follow_mode


## Assigns a new [Node2D] as the [member follow_target].
func set_follow_target(value: Node2D) -> void:
	if follow_mode == FollowMode.NONE or follow_mode == FollowMode.GROUP: return
	if follow_target == value: return
	follow_target = value
	_follow_target_physics_based = false
	if is_instance_valid(value):
		if follow_mode == FollowMode.PATH:
			if is_instance_valid(follow_path):
				_should_follow = true
			else:
				_should_follow = false
		else:
			_should_follow = true
		_check_physics_body(value)
		if not follow_target.tree_exiting.is_connected(_follow_target_tree_exiting):
			follow_target.tree_exiting.connect(_follow_target_tree_exiting.bind(follow_target))
	else:
		_should_follow = false
	_reset_lookahead()
	follow_target_changed.emit()
	notify_property_list_changed()

## Erases the current [member follow_target].
func erase_follow_target() -> void:
	if follow_target == null: return
	_should_follow = false
	follow_target = null
	_follow_target_physics_based = false
	_character_body_2d = null
	_rigid_body_2d = null
	_follow_target_physics_class = FollowTargetPhysicsClass.OTHER
	follow_target_changed.emit()

## Gets the current [member follow_target].
func get_follow_target() -> Node2D:
	return follow_target


## Assigns a new [Path2D] to the [member follow_path].
func set_follow_path(value: Path2D) -> void:
	follow_path = value
	if is_instance_valid(follow_path):
		_should_follow_checker()
	else:
		_should_follow = false

## Erases the current [Path2D] from the [member follow_path] property.
func erase_follow_path() -> void:
	follow_path = null

## Gets the current [Path2D] from the [member follow_path].
func get_follow_path() -> Path2D:
	return follow_path


## Assigns a new [param follow_targets] array value.
func set_follow_targets(value: Array[Node2D]) -> void:
	if follow_mode != FollowMode.GROUP: return
	if follow_targets == value: return
	follow_targets = value
	_follow_targets_size_check()
	_reset_lookahead()

## Appends a single [Node2D] to [member follow_targets].
func append_follow_targets(value: Node2D) -> void:
	if not is_instance_valid(value):
		printerr(value, " is not a valid Node2D instance")
		return

	if not follow_targets.has(value):
		follow_targets.append(value)
		_follow_targets_size_check()
	else:
		printerr(value, " is already part of Follow Group")

## Adds an Array of type [Node2D] to [member follow_targets].
func append_follow_targets_array(value: Array[Node2D]) -> void:
	for target in value:
		if not is_instance_valid(target): continue
		if not follow_targets.has(target):
			follow_targets.append(target)
			_follow_targets_size_check()
		else:
			printerr(value, " is already part of Follow Group")

## Removes a [Node2D] from [member follow_targets] array.
func erase_follow_targets(value: Node2D) -> void:
	follow_targets.erase(value)
	_follow_targets_size_check()

## Gets all [Node2D] from [member follow_targets] array.
func get_follow_targets() -> Array[Node2D]:
	return follow_targets


## Assigns a new Vector2 for the Follow Target Offset property.
func set_follow_offset(value: Vector2) -> void:
	var temp_offset: Vector2 = follow_offset

	follow_offset = value

	if follow_axis_lock != FollowLockAxis.NONE:
		temp_offset = temp_offset - value
		match value:
			FollowLockAxis.X:
				_follow_axis_lock_value.x = _transform_output.origin.x + temp_offset.x
			FollowLockAxis.Y:
				_follow_axis_lock_value.y = _transform_output.origin.y + temp_offset.y
			FollowLockAxis.XY:
				_follow_axis_lock_value.x = _transform_output.origin.x + temp_offset.x
				_follow_axis_lock_value.y = _transform_output.origin.y + temp_offset.y


## Gets the current Vector2 for the Follow Target Offset property.
func get_follow_offset() -> Vector2:
	return follow_offset


## Enables or disables Follow Damping.
func set_follow_damping(value: bool) -> void:
	follow_damping = value
	notify_property_list_changed()

## Gets the current Follow Damping property.
func get_follow_damping() -> bool:
	return follow_damping


## Assigns new Damping value.
func set_follow_damping_value(value: Vector2) -> void:
	follow_damping_value = Vector2(
		maxf(0.0, value.x),
		maxf(0.0, value.y),
	)

## Gets the current Follow Damping value.
func get_follow_damping_value() -> Vector2:
	return follow_damping_value


## Assigns a new [member follow_axis] member. Value is based on [enum FollowLockAxis] enum.
func set_lock_axis(value: FollowLockAxis) -> void:
	follow_axis_lock = value

	# Wait for the node to be ready before setting lock
	if not is_node_ready(): await ready

	# Prevent axis lock from working in the editor
	if value != FollowLockAxis.NONE and not Engine.is_editor_hint():
		_follow_axis_is_locked = true
		match value:
			FollowLockAxis.X:
				_follow_axis_lock_value.x = _transform_output.origin.x
			FollowLockAxis.Y:
				_follow_axis_lock_value.y = _transform_output.origin.y
			FollowLockAxis.XY:
				_follow_axis_lock_value.x = _transform_output.origin.x
				_follow_axis_lock_value.y = _transform_output.origin.y
	else:
		_follow_axis_is_locked = false

## Gets the current [member follow_axis_lock] value. Value is based on [enum FollowLockAxis] enum.
func get_lock_axis() -> FollowLockAxis:
	return follow_axis_lock


## Enables or disables [member rotate_with_target].
func set_rotate_with_target(value: bool) -> void:
	rotate_with_target = value
	notify_property_list_changed()

## Gets the current [member rotate_with_target] value.
func get_rotate_with_target() -> bool:
	return rotate_with_target


## Sets the [member rotation_offset].
func set_rotation_offset(value: float) -> void:
	rotation_offset = value

## Gets the current [member rotation_offset] value.
func get_rotation_offset() -> float:
	return rotation_offset


## Enables or disables [member rotation_damping].
func set_rotation_damping(value: bool) -> void:
	rotation_damping = value
	notify_property_list_changed()

## Gets the [member rotation_damping] value.
func get_rotation_damping() -> bool:
	return rotation_damping


## Set the [member rotation_damping_value].
func set_rotation_damping_value(value: float) -> void:
	rotation_damping_value = value

## Gets the [member rotation_damping_value] value.
func get_rotation_damping_value() -> float:
	return rotation_damping_value


## Enables or disables [member snap_to_pixel].
func set_snap_to_pixel(value: bool) -> void:
	snap_to_pixel = value

## Gets the current [member snap_to_pixel] value.
func get_snap_to_pixel() -> bool:
	return snap_to_pixel


## Enables or disables Auto zoom when using Group Follow.
func set_auto_zoom(value: bool) -> void:
	auto_zoom = value
	notify_property_list_changed()

## Gets Auto Zoom state.
func get_auto_zoom() -> bool:
	return auto_zoom


## Assigns new Min Auto Zoom value.
func set_auto_zoom_min(value: float) -> void:
	auto_zoom_min = value

## Gets Min Auto Zoom value.
func get_auto_zoom_min() -> float:
	return auto_zoom_min


## Assigns new Max Auto Zoom value.
func set_auto_zoom_max(value: float) -> void:
	auto_zoom_max = value

## Gets Max Auto Zoom value.
func get_auto_zoom_max() -> float:
	return auto_zoom_max


## Assigns new Zoom Auto Margin value.
func set_auto_zoom_margin(value: Vector4) -> void:
	auto_zoom_margin = value

## Gets Zoom Auto Margin value.
func get_auto_zoom_margin() -> Vector4:
	return auto_zoom_margin


func set_lookahead(value: bool) -> void:
	lookahead = value
	_reset_lookahead()
	notify_property_list_changed()

func get_lookahead() -> bool:
	return lookahead


func set_lookahead_time(value: Vector2) -> void:
	lookahead_time = Vector2(
		maxf(0.0, value.x),
		maxf(0.0, value.y)
	)

func get_lookahead_time() -> Vector2:
	return lookahead_time


func set_lookahead_max(value: bool) -> void:
	lookahead_max = value
	notify_property_list_changed()

func get_lookahead_max() -> bool:
	return lookahead_max


func set_lookahead_max_value(value: Vector2) -> void:
	lookahead_max_value = Vector2(
		maxf(0.0, value.x),
		maxf(0.0, value.y)
	)

func get_lookahead_max_value() -> Vector2:
	return lookahead_max_value


func set_lookahead_acceleration(value: float) ->  void:
	lookahead_acceleration = maxf(0.0, value)
	if is_zero_approx(lookahead_acceleration):
		_has_lookahead_acceleration = false
	else:
		_has_lookahead_acceleration = true

func get_lookahead_acceleration() -> float:
	return lookahead_acceleration


func set_lookahead_deceleration(value: float) ->  void:
	lookahead_deceleration = maxf(0.0, value)
	if is_zero_approx(lookahead_deceleration):
		_has_lookahead_deceleration = false
	else:
		_has_lookahead_deceleration = true

func get_lookahead_deceleration() -> float:
	return lookahead_deceleration


## Sets a limit side based on the side parameter.[br]
## It's recommended to pass the [enum Side] enum as the sid parameter.
func set_limit(side: int, value: int) -> void:
	match side:
		SIDE_LEFT:      limit_left = value
		SIDE_TOP:       limit_top = value
		SIDE_RIGHT:     limit_right = value
		SIDE_BOTTOM:    limit_bottom = value
		_: printerr("Not a valid Side.")

## Gets the limit side
func get_limit(value: int) -> int:
	match value:
		SIDE_LEFT:      return limit_left
		SIDE_TOP:       return limit_top
		SIDE_RIGHT:     return limit_right
		SIDE_BOTTOM:    return limit_bottom
		_:
						printerr("Not a valid Side.")
						return -1


## Assign a the Camera2D Left Limit Side value.
func set_limit_left(value: int) -> void:
	_limit_target_exist_error()
	limit_left = value
	update_limit_all_sides()

## Gets the Camera2D Left Limit value.
func get_limit_left() -> int:
	return limit_left


## Assign a the Camera2D Top Limit Side value.
func set_limit_top(value: int) -> void:
	_limit_target_exist_error()
	limit_top = value
	update_limit_all_sides()

## Gets the Camera2D Top Limit value.
func get_limit_top() -> int:
	return limit_top


## Assign a the Camera2D Right Limit Side value.
func set_limit_right(value: int) -> void:
	_limit_target_exist_error()
	limit_right = value
	update_limit_all_sides()

## Gets the Camera2D Right Limit value.
func get_limit_right() -> int:
	return limit_right


## Assign a the Camera2D Bottom Limit Side value.
func set_limit_bottom(value: int) -> void:
	_limit_target_exist_error()
	limit_bottom = value
	update_limit_all_sides()

## Gets the Camera2D Bottom Limit value.
func get_limit_bottom() -> int:
	return limit_bottom


func _limit_target_exist_error() -> void:
	if not limit_target.is_empty():
		printerr("Unable to set Limit Side due to Limit Target ", _limit_node.name, " being assigned")


# Sets a [memeber limit_target] node.
func set_limit_target(value: NodePath) -> void:
	limit_target = value

	# Waits for PCam2d's _ready() before trying to validate limit_node_path
	if not is_node_ready(): await ready

	# Removes signal from existing TileMapLayer node
	if is_instance_valid(get_node_or_null(value)):
		var prev_limit_node: Node2D = _limit_node
		var new_limit_node: Node2D = get_node(value)

		if prev_limit_node:
			if prev_limit_node is TileMapLayer:
				if prev_limit_node.changed.is_connected(_on_tile_map_changed):
					prev_limit_node.changed.disconnect(_on_tile_map_changed)

		if new_limit_node is TileMapLayer:
			if not new_limit_node.changed.is_connected(_on_tile_map_changed):
				new_limit_node.changed.connect(_on_tile_map_changed)
		elif new_limit_node is CollisionShape2D:
			var col_shape: CollisionShape2D = get_node(value)

			if col_shape.shape == null:
				printerr("No Shape2D in: ", col_shape.name)
				reset_limit()
				limit_target = NodePath("")
				return
		else:
			printerr("Limit Target is not a TileMapLayer or CollisionShape2D node")
			return
	elif value == NodePath(""):
		reset_limit()
		limit_target = NodePath("")
	else:
		printerr("Limit Target cannot be found")
		return

	_limit_node = get_node_or_null(value)

	notify_property_list_changed()
	update_limit_all_sides()

## Get [member limit_target] node.
func get_limit_target() -> NodePath:
	if not limit_target: # TODO - Fixes an spam error if if limit_taret is empty
		return NodePath("")
	else:
		return limit_target


## Set Tile Map Limit Margin.
func set_limit_margin(value: Vector4i) -> void:
	limit_margin = value
	update_limit_all_sides()
## Get Tile Map Limit Margin.
func get_limit_margin() -> Vector4i:
	return limit_margin


### Enables or disables the Limit Smoothing beaviour.
#func set_limit_smoothing(value: bool) -> void:
	#limit_smoothed = value
### Returns the Limit Smoothing beaviour.
#func get_limit_smoothing() -> bool:
	#return limit_smoothed


## Sets a [PhantomCameraNoise2D] resource.
func set_noise(value: PhantomCameraNoise2D) -> void:
	noise = value
	if value != null:
		_has_noise_resource = true
		noise.set_trauma(1.0)
	else:
		_has_noise_resource = false
		_transform_noise = Transform2D()

## Returns the [PhantomCameraNoise2D] resource.
func get_noise() -> PhantomCameraNoise2D:
	return noise

func has_noise_resource() -> bool:
	return _has_noise_resource


## Sets the [member noise_emitter_layer] value.
func set_noise_emitter_layer(value: int) -> void:
	noise_emitter_layer = value

## Enables or disables a given layer of [member noise_emitter_layer].
func set_noise_emitter_layer_value(value: int, enabled: bool) -> void:
	noise_emitter_layer = _set_layer(noise_emitter_layer, value, enabled)

## Returns the [member noise_emitter_layer]
func get_noise_emitter_layer() -> int:
	return noise_emitter_layer


## Sets [member inactive_update_mode] property.
func set_inactive_update_mode(value: int) -> void:
	inactive_update_mode = value

## Gets [enum InactiveUpdateMode] value.
func get_inactive_update_mode() -> int:
	return inactive_update_mode


func get_follow_target_physics_based() -> bool:
	return _follow_target_physics_based


func get_class() -> String:
	return "PhantomCamera2D"


func is_class(value) -> bool:
	return value == "PhantomCamera2D"

#endregion
