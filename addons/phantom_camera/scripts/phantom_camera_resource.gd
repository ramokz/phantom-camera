#@tool
#extends Node
#
#var _if_phantom_camera_3D: bool
#var _if_phantom_camera_2D: bool
#
#var _has_follow_target: bool = false
#var _follow_target: NodePath
#var _look_at_target: NodePath
#var _has_look_at_target: bool = false
#
#var _follow_target_offset: Vector3
#
#var follow_target_node: Node
#var look_at_target_node: Node
#
#func is_2D_phantom_camera() -> void:
#	_if_phantom_camera_2D = true
#	notify_property_list_changed()
#
#func is_3D_phantom_camera() -> void:
#	_if_phantom_camera_3D = true
#	notify_property_list_changed()
#
#func _get_property_list() -> Array:
#	var ret: Array
#
#	if _if_phantom_camera_2D:
#		property_listappend({
#			"name": "Follow Target 2D",
#			"type": TYPE_VECTOR2,
#			"hint": PROPERTY_HINT_NONE,
#			"usage": PROPERTY_USAGE_DEFAULT
#		})
#
#	if _if_phantom_camera_3D:
#		property_listappend({
#			"name": "Follow Target 3D",
#			"type": TYPE_NODE_PATH,
#			"hint": PROPERTY_HINT_NONE,
#			"usage": PROPERTY_USAGE_DEFAULT
#		})
#
#		property_listappend({
#			"name": "Look At Target 3D",
#			"type": TYPE_NODE_PATH,
#			"hint": PROPERTY_HINT_NONE,
#			"usage": PROPERTY_USAGE_DEFAULT
#		})
#
#		if _has_look_at_target:
#			property_listappend({
#				"name": "Look At Target Offset 3D",
#				"type": TYPE_VECTOR3,
#				"hint": PROPERTY_HINT_NONE,
#				"usage": PROPERTY_USAGE_DEFAULT
#			})
#
#	if _has_follow_target:
#		property_listappend({
#			"name": "Follow Target Offset",
#			"type": TYPE_VECTOR3,
#			"hint": PROPERTY_HINT_NONE,
#			"usage": PROPERTY_USAGE_DEFAULT
#		})
#
#	return ret
#
#func _set(property: StringName, value) -> bool:
#	var retval: bool = true
#
#	if property == "Follow Target 3D":
#		_follow_target = value
#		var valueNodePath: NodePath = value as NodePath
#		if not valueNodePath.is_empty():
#			_has_follow_target = true
##			if has_node(_follow_target):
##				look_at_target_node = get_node(_follow_target)
#		else:
#			_has_follow_target = false
#			follow_target_node = null
#
#		notify_property_list_changed()
#
#	if property == "Look At Target 3D":
#		_look_at_target = value
#		var valueNodePath: NodePath = value as NodePath
#		if not valueNodePath.is_empty():
#			_has_look_at_target = true
##			if has_node(_look_at_target):
##				look_at_target_node = get_node(_look_at_target)
#		else:
#			_has_look_at_target = false
#			look_at_target_node = null
#
#		notify_property_list_changed()
#
#	return false
#
#func _get(property: StringName):
#	if property == "Follow Target 3D": return _follow_target
#	if property == "Look At Target 3D": return _look_at_target
