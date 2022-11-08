@tool
extends Node3D

var look_at_target_node: Node3D
@export var look_at_target_path: NodePath:
	set(value):
		look_at_target_path = value
		if has_node(look_at_target_path):
			look_at_target_node = get_node(look_at_target_path)

var follow_target_node: Node3D
@export var follow_target_path: NodePath:
	set(value):
		follow_target_path = value
		if has_node(follow_target_path):
			follow_target_node = get_node(follow_target_path)

@export var is_camera_active: bool: set = set_active_camera
@export_range(0, 100, 1, "or_greater") var camera_smoothing: float = 0

@export var follow_offset: Vector3
@export var look_offset: Vector3

var _initial_position: Vector3 = position
var _follow_target_initial_position: Vector3
var _set_initial_position: bool = false

#func _ready() -> void:
#	if look_at_target_path:
#		_look_at_target_node = get_node(look_at_target_path)
#
#	if follow_target_path:
#		_follow_target_node = get_node(follow_target_path)

func _enter_tree() -> void:
	add_to_group(PhantomCameraManager.PHANTOM_CAMERA_GROUP_NAME)
	if is_camera_active:
		PhantomCameraManager.set_active_cam(self)

	if look_at_target_path:
		look_at_target_node = get_node(look_at_target_path)

	if follow_target_path:
		follow_target_node = get_node(follow_target_path)
#		set_position(_follow_target_node.position)

	PhantomCameraManager.phantom_camera_added_to_scene(self)

func _exit_tree() -> void:
	remove_from_group(PhantomCameraManager.PHANTOM_CAMERA_GROUP_NAME)
	if is_camera_active:
		PhantomCameraManager.remove_phan_cam_from_list(self)


func set_active_camera(state: bool) -> void:
	is_camera_active = !is_camera_active

	if state == true:
		PhantomCameraManager.set_active_cam(self)
		is_camera_active = true
	else:
		PhantomCameraManager.remove_phan_cam_from_list(self)
		is_camera_active = false
#	elif not is_camera_active and PhantomCameraBase._active_camera == self:
	if follow_target_node:
		print("Follow target exists")
#		print(follow_target.position)
		_follow_target_initial_position = follow_target_node.position


func _process(delta: float) -> void:
#	 TODO - Should only follow if currently active camera
	if follow_target_node:
		if camera_smoothing == 0:
			set_position(
				follow_target_node.position + follow_offset
#				_follow_target_node.position - _follow_target_initial_position + follow_offset
			)
		else:
			# TODO - Change camera_smoothing value to something more sensible in the editor
			set_position(
				position.lerp(
					follow_target_node.position + follow_offset,
					delta / camera_smoothing * 10
				)
			)

	if look_at_target_node:
		look_at(look_at_target_node.position + look_offset)


#func _set_position() -> void:
#	set_position(_follow_target.position)



