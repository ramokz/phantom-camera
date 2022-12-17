@tool
extends Node

var editor_interface: EditorInterface
var phantom_camera_list_item := preload("res://addons/phantom_camera/editor/phantom_camera_list_item.tscn")

var camera_list: VBoxContainer = $VBoxContainer/ScrollContainer/PhantomCameraList

var phantom_camera_group: Array[Node]

#	TODO - Enable once Editor work resumes

#func _enter_tree() -> void:
#	print("Editor Entered Tree")
#	connect("visibility_changed", _check_visibility)
#
#func _exit_tree() -> void:
#	disconnect("visibility_changed", _check_visibility)
#
#func _check_visibility() -> void:
#	print("Visibility changed")
#	print("Visibility is: ", is_inside_tree())
#	print(get_child(0))
#
#	for n in %PhantomCameraList.get_children():
#		%PhantomCameraList.remove_child(n)
#		n.queue_free()
#
#	if get_tree().get_nodes_in_group(PhantomCameraManager.PHANTOM_CAMERA_GROUP_NAME):
#		phantom_camera_group = get_tree().get_nodes_in_group(PhantomCameraManager.PHANTOM_CAMERA_GROUP_NAME)
#		for n in phantom_camera_group:
#			var _phantom_camera_list_item_instance = phantom_camera_list_item.instantiate()
#
#			var _phantom_camera_name: String = n.get_name()
#
#			var _phantom_camera_follow_target: String = ""
#			if n.follow_target_node:
#				_phantom_camera_follow_target = n.follow_target_node.get_name()
#
#			_phantom_camera_list_item_instance.init(_phantom_camera_name, _phantom_camera_follow_target)
#			%PhantomCameraList.add_child(_phantom_camera_list_item_instance)
#	else:
#		print("No phantom cameras in tree")
