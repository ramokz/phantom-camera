@tool
extends RefCounted

const PhantomCameraHost: Script = preload("res://addons/phantom_camera/scripts/phantom_camera_host/phantom_camera_host.gd")

# Primary
const PRIORITY_PROPERTY_NAME: StringName = "Priority"

const PCAM_HOST: StringName = "Phantom Camera Host"

const TRIGGER_ONLOAD_NAME: StringName = "Trigger on Load"

# Follow
const FOLLOW_MODE_PROPERTY_NAME: StringName = "Follow Mode"
const FOLLOW_TARGET_PROPERTY_NAME: StringName = "Follow Target"
const FOLLOW_GROUP_PROPERTY_NAME: StringName = "Follow Group"
const FOLLOW_PATH_PROPERTY_NAME: StringName = "Follow Path"
const FOLLOW_PARAMETERS_NAME: StringName = "Follow Parameters/"

# Follow Parameters
const FOLLOW_DISTANCE_PROPERTY_NAME: StringName = FOLLOW_PARAMETERS_NAME + "Distance"
const FOLLOW_DAMPING_NAME: StringName = FOLLOW_PARAMETERS_NAME + "Damping"
const FOLLOW_DAMPING_VALUE_NAME: StringName = FOLLOW_PARAMETERS_NAME + "Damping Value"
const FOLLOW_TARGET_OFFSET_PROPERTY_NAME: StringName = FOLLOW_PARAMETERS_NAME + "Target Offset"

# Tween Resource
const TWEEN_RESOURCE_PROPERTY_NAME: StringName = "Tween Parameters"

# Secondary
const INACTIVE_UPDATE_MODE_PROPERTY_NAME: StringName = "Inactive Update Mode"


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
	ALWAYS 			= 0,
#	EXPONENTIALLY 	= 1,
	NEVER 			= 2,
}
