extends RefCounted

const PhantomCameraVariables = preload("phantom_camera_variables.gd")
const PhantomCameraHost = preload("res://addons/phantom_camera/scripts/phantom_camera_host/phantom_camera_host.gd")

const PRIORITY_PROPERTY_NAME: StringName = "Priority"
const PHANTOM_CAMERA_GROUP_NAME: StringName = "phantom_camera_group"
const PHANTOM_CAMERA_HOST_GROUP_NAME: StringName = "phantom_camera_host_group"

const FOLLOW_TARGET_PROPERTY_NAME: StringName = "Follow Target"

const FOLLOW_PARAMETERS_STRINGNAME: StringName = "Follow Parameters/"
const FOLLOW_TARGET_OFFSET_PROPERTY_NAME: StringName = FOLLOW_PARAMETERS_STRINGNAME + "Follow Target Offset"

# TWEEN Variables
const TWEEN_CATEGORY_NAME: StringName = "Tween Propertieszz/"
const TWEEN_TRANSITION_PROPERTY_NAME: StringName = TWEEN_CATEGORY_NAME + "Transition"
const TWEEN_EASE_PROPERTY_NAME: StringName = TWEEN_CATEGORY_NAME + "Ease"
const TWEEN_DURATION_PROPERTY_NAME: StringName = TWEEN_CATEGORY_NAME + "Duration"

enum TweenTransitions {
	TRANS_LINEAR = 0,
	TRANS_SINE = 1,
	TRANS_QUINT = 2,
	TRANS_QUART = 3,
	TRANS_QUAD = 4,
	TRANS_EXPO = 5,
	TRANS_ELASTIC = 6,
	TRANS_CUBIC = 7,
	TRANS_CIRC = 8,
	TRANS_BOUNCE = 9,
	TRANS_BACK = 10,
	CUSTOM = 11
}


enum TweenEases {
	EASE_IN = 0,
	EASE_OUT = 1,
	EASE_IN_OUT = 2,
	EASE_OUT_IN = 3,
}
