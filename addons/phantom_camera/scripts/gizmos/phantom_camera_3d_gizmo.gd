@tool
extends EditorNode3DGizmo

var pcam_3d: PhantomCamera3D

func _redraw() -> void:
	clear()

	var icon: Material = get_plugin().get_material(get_plugin().get_name(), self)
	add_unscaled_billboard(icon, 0.035)

	pcam_3d = get_node_3d()

	if pcam_3d.is_following() and pcam_3d.draw_follow_gizmo_line():
		_draw_target(pcam_3d.get_follow_target_position(), "follow_target")
	if pcam_3d.is_looking() and pcam_3d.draw_look_at_gizmo_line():
		_draw_target(pcam_3d.get_look_at_target_position(),"look_at_target")

	if pcam_3d.is_active(): return

	var frustum_lines: PackedVector3Array = PackedVector3Array()
	var height: float                     = 0.25
	var width: float                      = height * 1.25
	var forward: float                    = height * -1.5

	# Trapezoid
	frustum_lines.push_back(Vector3.ZERO)
	frustum_lines.push_back(Vector3(-width, height, forward))

	frustum_lines.push_back(Vector3.ZERO)
	frustum_lines.push_back(Vector3(width, height, forward))

	frustum_lines.push_back(Vector3.ZERO)
	frustum_lines.push_back(Vector3(-width, -height, forward))

	frustum_lines.push_back(Vector3.ZERO)
	frustum_lines.push_back(Vector3(width, -height, forward))

	#######
	# Frame
	#######
	## Left
	frustum_lines.push_back(Vector3(-width, height, forward))
	frustum_lines.push_back(Vector3(-width, -height, forward))

	## Bottom
	frustum_lines.push_back(Vector3(-width, -height, forward))
	frustum_lines.push_back(Vector3(width, -height, forward))

	## Right
	frustum_lines.push_back(Vector3(width, -height, forward))
	frustum_lines.push_back(Vector3(width, height, forward))

	## Top
	frustum_lines.push_back(Vector3(width, height, forward))
	frustum_lines.push_back(Vector3(-width, height, forward))

	##############
	# Up Direction
	##############
	var up_height: float = height + 0.15
	var up_width: float = width / 3

	## Left
	frustum_lines.push_back(Vector3(0, up_height, forward))
	frustum_lines.push_back(Vector3(-up_width, height, forward))

	## Right
	frustum_lines.push_back(Vector3(0, up_height, forward))
	frustum_lines.push_back(Vector3(up_width, height, forward))

	var frustum_material: StandardMaterial3D = get_plugin().get_material("frustum", self)
	add_lines(frustum_lines, frustum_material, false)


func _draw_target(target: Vector3, type: StringName) -> void:
	var target_lines: PackedVector3Array = PackedVector3Array()
	var direction: Vector3 = pcam_3d.global_position - target
	var end_position: Vector3 = -direction * pcam_3d.quaternion

	target_lines.push_back(Vector3.ZERO)
	target_lines.push_back(end_position)

	var target_material: StandardMaterial3D = get_plugin().get_material(type, self)
	add_lines(target_lines, target_material, false)
