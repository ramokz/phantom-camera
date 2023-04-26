@tool
extends RefCounted

const PhantomCameraHost: Script = preload("res://addons/phantom_camera/scripts/phantom_camera_host/phantom_camera_host.gd")

# Primary
const PRIORITY_PROPERTY_NAME: StringName = "priority"

const PCAM_HOST: StringName = "phantom_camera_host"

# Follow
const FOLLOW_MODE_PROPERTY_NAME: StringName = "follow_mode"
const FOLLOW_TARGET_PROPERTY_NAME: StringName = "follow_target"
const FOLLOW_GROUP_PROPERTY_NAME: StringName = "follow_group"
const FOLLOW_PATH_PROPERTY_NAME: StringName = "follow_path"
const FOLLOW_PARAMETERS_NAME: StringName = "follow_parameters/"

# Follow Parameters
const FOLLOW_DISTANCE_PROPERTY_NAME: StringName = FOLLOW_PARAMETERS_NAME + "distance"
const FOLLOW_DAMPING_NAME: StringName = FOLLOW_PARAMETERS_NAME + "damping"
const FOLLOW_DAMPING_VALUE_NAME: StringName = FOLLOW_PARAMETERS_NAME + "damping_value"
const FOLLOW_TARGET_OFFSET_PROPERTY_NAME: StringName = FOLLOW_PARAMETERS_NAME + "target_offset"

#Zoom
const ZOOM_PROPERTY_NAME: StringName = "zoom"


# Tween Resource
const TWEEN_RESOURCE_PROPERTY_NAME: StringName = "tween_parameters"

# Secondary
const TWEEN_ONLOAD_NAME: StringName = "tween_on_load"
const INACTIVE_UPDATE_MODE_PROPERTY_NAME: StringName = "inactive_update_mode"


enum FollowMode {
	NONE 	= 0,
	GLUED 	= 1,
	SIMPLE 	= 2,
	GROUP	= 3,
	PATH	= 4,
#	FRAMED_FOLLOW 	= 3,
#	TODO - Path Track Follow
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
