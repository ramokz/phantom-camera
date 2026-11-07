@tool
class_name PhantomCameraDebugger
extends EditorDebuggerPlugin


#region Private Variables

const _constants = preload("res://addons/phantom_camera/scripts/phantom_camera/phantom_camera_constants.gd")
var _initial_drag: bool = true
var _prev_drag_dead_zone: Vector2

#endregion

#region Signals

signal dead_zone_updated

#endregion

#region Private Functions

func _has_capture(capture: String) -> bool:
	return capture == _constants.DEBUG_PCAM


func _capture(message: String, data: Array, session_id: int) -> bool:
	if message == _constants.DEBUG_PCAM_DEAD_ZONE_UPDATE:
		get_session(session_id).send_message(_constants.DEBUG_PCAM_ECHO, data)
		update_editor_dead_zone(data)
		return true
	return false


func update_editor_dead_zone(data: Array) -> void:
	var pcam: Node = EditorInterface.get_edited_scene_root().get_node_or_null(data[0])
	if not is_instance_valid(pcam): return

	var property: StringName = data[1]
	var is_vector_y: int = data[2]
	var value: float = data[3]
	var commit_save: bool = data[4]

	var dead_zone_value: Vector2 = pcam.get(property)

	if _initial_drag:
		_prev_drag_dead_zone = dead_zone_value
		_initial_drag = false

	if not is_vector_y:
		dead_zone_value.x = value
	else:
		dead_zone_value.y = value

	if commit_save:
		var undo_redo: EditorUndoRedoManager = Engine.get_singleton(&"EditorInterface").get_editor_undo_redo()
		undo_redo.create_action("Changed" + pcam.name + "'s Dead Zone")
		undo_redo.add_do_property(pcam, property, dead_zone_value)
		undo_redo.add_undo_property(pcam, property, _prev_drag_dead_zone)
		undo_redo.commit_action()
		_initial_drag = true

	pcam.set(property, dead_zone_value)

#endregion
