@tool
extends RefCounted

const PhantomCameraHost: Script = preload("res://addons/phantom_camera/scripts/phantom_camera_host/phantom_camera_host.gd")

const PRIORITY_PROPERTY_NAME: StringName = "Priority"

const PCAM_HOST: StringName = "Phantom Camera Host"

const TRIGGER_ONLOAD_NAME: StringName = "Trigger on Load"

const FOLLOW_TARGET_PROPERTY_NAME: StringName = "Follow Target"
const FOLLOW_PARAMETERS_NAME: StringName = "Follow Parameters/"
const FOLLOW_DAMPING_NAME: StringName = FOLLOW_PARAMETERS_NAME + "Damping"
const FOLLOW_DAMPING_VALUE_NAME: StringName = FOLLOW_PARAMETERS_NAME + "Damping Value"
const FOLLOW_TARGET_OFFSET_PROPERTY_NAME: StringName = FOLLOW_PARAMETERS_NAME + "Target Offset"

const TWEEN_CATEGORY_NAME: StringName = "Tween Properties/"
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
