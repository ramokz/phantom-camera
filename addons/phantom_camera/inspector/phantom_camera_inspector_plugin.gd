@tool
extends EditorInspectorPlugin

var _phantom_camera_script: Script = preload("res://addons/phantom_camera/phantom_camera.gd")

func _can_handle(object) -> bool:
	return object is _phantom_camera_script


func _parse_category(object: Object, category: String) -> void:
	var align_with_view_button = Button.new()
	align_with_view_button.connect("pressed", _align_camera_with_view.bind(object))
	align_with_view_button.set_text("Align with view")
#	print("Object is: ", object)
#	print("Category is: ", category)
	add_custom_control(align_with_view_button)


func _align_camera_with_view(object: Object) -> void:
	print("Aligning camera with view")
	print(object)
