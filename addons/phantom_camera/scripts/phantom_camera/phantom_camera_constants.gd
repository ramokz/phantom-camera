@tool
extends RefCounted

const PhantomCameraHost: Script = preload("res://addons/phantom_camera/scripts/phantom_camera_host/phantom_camera_host.gd")

const PRIORITY_PROPERTY_NAME: StringName = "Priority"

const PCAM_HOST: StringName = "Phantom Camera Host"

const TRIGGER_ONLOAD_NAME: StringName = "Trigger on Load"

const FOLLOW_TARGET_PROPERTY_NAME: StringName = "Follow Target"
const FOLLOW_PARAMETERS_NAME: StringName = "Follow Parameters/"
const FOLLOW_MODE_PROPERTY_NAME: StringName = FOLLOW_PARAMETERS_NAME + "Follow Mode"
const FOLLOW_DISTANCE_PROPERTY_NAME: StringName = FOLLOW_PARAMETERS_NAME + "Distance"
const FOLLOW_DAMPING_NAME: StringName = FOLLOW_PARAMETERS_NAME + "Damping"
const FOLLOW_DAMPING_VALUE_NAME: StringName = FOLLOW_PARAMETERS_NAME + "Damping Value"
const FOLLOW_TARGET_OFFSET_PROPERTY_NAME: StringName = FOLLOW_PARAMETERS_NAME + "Target Offset"

const TWEEN_CATEGORY_NAME: StringName = "Tween Properties/"
const TWEEN_TRANSITION_PROPERTY_NAME: StringName = TWEEN_CATEGORY_NAME + "Transition"
const TWEEN_EASE_PROPERTY_NAME: StringName = TWEEN_CATEGORY_NAME + "Ease"
const TWEEN_DURATION_PROPERTY_NAME: StringName = TWEEN_CATEGORY_NAME + "Duration"

enum FollowMode {
	NONE = 0,
	SIMPLE_FOLLOW = 1,
	FRAMED_FOLLOW = 2,
	GLUED_FOLLOW = 3,
#	TODO - Path Track Follow
}

enum TweenTransitions {
	LINEAR = 0,
	SINE = 1,
	QUINT = 2,
	QUART = 3,
	QUAD = 4,
	EXPO = 5,
	ELASTIC = 6,
	CUBIC = 7,
	CIRC = 8,
	BOUNCE = 9,
	BACK = 10,
#	TODO - CUSTOM = 11
}

enum TweenEases {
	EASE_IN = 0,
	EASE_OUT = 1,
	EASE_IN_OUT = 2,
	EASE_OUT_IN = 3,
}
