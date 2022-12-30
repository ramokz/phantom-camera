@tool
extends EditorInspectorPlugin

#var _phantom_camera_script: Script = preload("res://addons/phantom_camera/scripts/phantom_camera.gd")


# 	TODO - Enable again once work is resumed for inspector based tasks

#func _can_handle(object) -> bool:
#	return object is _phantom_camera_script


func _parse_category(object: Object, category: String) -> void:

	var _margin_container: MarginContainer = MarginContainer.new()
	var _margin_v: float = 20
	_margin_container.add_theme_constant_override("margin_left", 10)
	_margin_container.add_theme_constant_override("margin_top", _margin_v)
	_margin_container.add_theme_constant_override("margin_right", 10)
	_margin_container.add_theme_constant_override("margin_bottom", _margin_v)
	add_custom_control(_margin_container)

	var _vbox_container: VBoxContainer = VBoxContainer.new()
	_margin_container.add_child(_vbox_container)

	var align_with_view_button = Button.new()
	align_with_view_button.connect("pressed", _align_camera_with_view.bind(object))
	align_with_view_button.set_custom_minimum_size(Vector2(0, 60))
	align_with_view_button.set_text("Align with view")
	_vbox_container.add_child(align_with_view_button)

	var preview_camera_button = Button.new()
	preview_camera_button.connect("pressed", _preview_camera.bind(object))
	preview_camera_button.set_custom_minimum_size(Vector2(0, 60))
	preview_camera_button.set_text("Preview Camera")
	_vbox_container.add_child(preview_camera_button)



func _align_camera_with_view(object: Object) -> void:
	print("Aligning camera with view")
	print(object)

func _preview_camera(object: Object) -> void:
	print("Previewing camera")
	print(object)
