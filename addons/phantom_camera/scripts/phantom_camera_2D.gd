@tool
extends Node2D

class_name PhantomCamera2D

@export var follow_offset: Vector2
@export var look_offset: Vector2

#func _enter_tree() -> void:
#	follow_target_node = follow_target_node as Node2D

#	TODO - Requires some refactoring

#func _process(delta: float) -> void:
##	 TODO - Should only follow if currently active camera
#	if follow_target_node:
#		if camera_smoothing == 0:
#			set_position(
#				follow_target_node.position + follow_offset
##				_follow_target_node.position - _follow_target_initial_position + follow_offset
#			)
#		else:
#			# TODO - Change camera_smoothing value to something more sensible in the editor
#			set_position(
#				position.lerp(
#					follow_target_node.position + follow_offset,
#					delta / camera_smoothing * 10
#				)
#			)
#
#	if look_at_target_node:
#		look_at(look_at_target_node.position + look_offset)
