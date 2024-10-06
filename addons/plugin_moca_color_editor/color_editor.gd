@tool
extends EditorPlugin

var control : Control

func _enter_tree() -> void:
	control = preload("res://addons/plugin_moca_color_editor/color_editor.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_BL,control)


func _exit_tree() -> void:
	remove_control_from_docks(control)
	control.queue_free()
