@tool
extends EditorInspectorPlugin

var _phantom_camera_script: Script = preload("res://addons/phantom_camera/phantom_camera.gd")

func _can_handle(object) -> bool:
	return object is _phantom_camera_script


func _parse_category(object: Object, category: String) -> void:
	var _margin_container: MarginContainer = MarginContainer.new()
#	_margin_container.add_theme_constant_override("margin_left", 10)
#	_margin_container.add_theme_constant_override("margin_top", 50)
#	_margin_container.add_theme_constant_override("margin_right", 10)
#	_margin_container.add_theme_constant_override("margin_bottom", 50)

	var align_with_view_button = Button.new()
	align_with_view_button.connect("pressed", _align_camera_with_view.bind(object))
	align_with_view_button.set_custom_minimum_size(Vector2(0, 60))
	align_with_view_button.set_text("Align with view")
#	print("Object is: ", object)
#	print("Category is: ", category)
	_margin_container.add_child(align_with_view_button)
	add_custom_control(_margin_container)


func _align_camera_with_view(object: Object) -> void:
	print("Aligning camera with view")
	print(object)
