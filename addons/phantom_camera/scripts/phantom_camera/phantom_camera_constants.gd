@tool
extends RefCounted

#region Constants

const PhantomCameraHost: Script = preload("res://addons/phantom_camera/scripts/phantom_camera_host/phantom_camera_host.gd")

const CAMERA_2D_NODE_NAME: StringName = "Camera2D"
const CAMERA_3D_NODE_NAME: StringName = "Camera3D"
const PCAM_HOST_NODE_NAME: StringName = "PhantomCameraHost"
const PCAM_2D_NODE_NAME: StringName = "PhantomCamera2D"
const PCAM_3D_NODE_NAME: StringName = "PhantomCamera3D"

const COLOR_2D: Color = Color("8DA5F3")
const COLOR_3D: Color = Color("FC7F7F")
const COLOR_PCAM: Color = Color("3AB99A")
const COLOR_PCAM_33: Color = Color("3ab99a33")
const PCAM_HOST_COLOR: Color = Color("E0E0E0")

const PRIORITY_PROPERTY_NAME: StringName = "priority"
const PRIORITY_OVERRIDE: StringName = "priority_override"
const PCAM_HOST: StringName = "phantom_camera_host"

const FOLLOW_MODE_PROPERTY_NAME: StringName = "follow_mode"
const FOLLOW_TARGET_PROPERTY_NAME: StringName = "follow_target"
const FOLLOW_GROUP_PROPERTY_NAME: StringName = "follow_group"
const FOLLOW_PATH_PROPERTY_NAME: StringName = "follow_path"
const FOLLOW_PARAMETERS_NAME: StringName = "follow_parameters/"

const FOLLOW_DISTANCE_PROPERTY_NAME: StringName = FOLLOW_PARAMETERS_NAME + "distance"
const FOLLOW_DAMPING_NAME: StringName = FOLLOW_PARAMETERS_NAME + "damping"
const FOLLOW_DAMPING_VALUE_NAME: StringName = FOLLOW_PARAMETERS_NAME + "damping_value"
const FOLLOW_TARGET_OFFSET_PROPERTY_NAME: StringName = FOLLOW_PARAMETERS_NAME + "target_offset"
const FOLLOW_FRAMED_DEAD_ZONE_HORIZONTAL_NAME: StringName = FOLLOW_PARAMETERS_NAME + "dead_zone_horizontal"
const FOLLOW_FRAMED_DEAD_ZONE_VERTICAL_NAME: StringName = FOLLOW_PARAMETERS_NAME + "dead_zone_vertical"
const FOLLOW_VIEWFINDER_IN_PLAY_NAME: StringName = FOLLOW_PARAMETERS_NAME + "viewfinder_in_play"
const DEAD_ZONE_CHANGED_SIGNAL: StringName = "dead_zone_changed"

const TWEEN_RESOURCE_PROPERTY_NAME: StringName = "tween_parameters"

const TWEEN_ONLOAD_NAME: StringName = "tween_on_load"
const INACTIVE_UPDATE_MODE_PROPERTY_NAME: StringName = "inactive_update_mode"

#endregion


#region Enums 

enum FollowMode {
	NONE 			= 0,
	GLUED 			= 1,
	SIMPLE 			= 2,
	GROUP 			= 3,
	PATH 			= 4,
	FRAMED 			= 5,
	THIRD_PERSON 	= 6,
}

enum TweenTransitions {
	LINEAR 	= 0,
	SINE 	= 1,
	QUINT 	= 2,
	QUART 	= 3,
	QUAD 	= 4,
	EXPO 	= 5,
	ELASTIC = 6,
	CUBIC 	= 7,
	CIRC 	= 8,
	BOUNCE 	= 9,
	BACK 	= 10,
#	CUSTOM 	= 11,
#	NONE 	= 12,
}

enum TweenEases {
	EASE_IN 	= 0,
	EASE_OUT 	= 1,
	EASE_IN_OUT = 2,
	EASE_OUT_IN = 3,
}

enum InactiveUpdateMode {
	ALWAYS,
	NEVER,
#	EXPONENTIALLY,
}

#endregion
