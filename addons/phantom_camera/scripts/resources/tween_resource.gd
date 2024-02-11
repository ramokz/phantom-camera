@icon("res://addons/phantom_camera/icons/phantom_camera_tween.svg")
class_name PhantomCameraTween
extends Resource

## Tweening resource for [PhantomCamera2D] and [PhantomCamera3D].
##
## Defines how [param PhantomCameras] transition between one another.
## Changing the tween values for a given [param PhantomCamera] determines how
## transitioning to that instance will look like.

enum TransitionType {
	LINEAR 	= 0, ## The animation is interpolated linearly.
	SINE 	= 1, ## The animation is interpolated using a sine function.
	QUINT 	= 2, ## The animation is interpolated with a quintic (to the power of 5) function.
	QUART 	= 3, ## The animation is interpolated with a quartic (to the power of 4) function.
	QUAD 	= 4, ## The animation is interpolated with a quadratic (to the power of 2) function.
	EXPO 	= 5, ## The animation is interpolated with an exponential (to the power of x) function.
	ELASTIC = 6, ## The animation is interpolated with elasticity, wiggling around the edges.
	CUBIC 	= 7, ## The animation is interpolated with a cubic (to the power of 3) function.
	CIRC 	= 8, ## The animation is interpolated with a function using square roots.
	BOUNCE 	= 9, ## The animation is interpolated by bouncing at the end.
	BACK 	= 10, ## The animation is interpolated backing out at ends.
#	CUSTOM 	= 11,
#	NONE 	= 12,
}

enum EaseType {
	EASE_IN 	= 0, ## The interpolation starts slowly and speeds up towards the end.
	EASE_OUT 	= 1, ## The interpolation starts quickly and slows down towards the end.
	EASE_IN_OUT = 2, ## A combination of EASE_IN and EASE_OUT. The interpolation is slowest at both ends.
	EASE_OUT_IN = 3, ## A combination of EASE_IN and EASE_OUT. The interpolation is fastest at both ends.
}

## The time it takes to tween to this PhantomCamera in [param seconds].
@export var duration: float = 1

## The transition bezier type for the tween. The options are defined in the [enum TransitionType].
@export var transition: TransitionType = TransitionType.LINEAR

## The ease type for the tween. The options are defined in the [enum EaseType].
@export var ease: EaseType = EaseType.EASE_IN_OUT
