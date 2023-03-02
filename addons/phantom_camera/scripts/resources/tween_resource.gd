class_name PhantomCameraTween
extends Resource

const Constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")

## The time it takes to tween to this property
@export var duration: float = 1

## The transition bezier type for the tween
@export var transition: Constants.TweenTransitions = Constants.TweenTransitions.LINEAR

## The ease type for the tween
@export var ease: Constants.TweenEases = Constants.TweenEases.EASE_IN_OUT
