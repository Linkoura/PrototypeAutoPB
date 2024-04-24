extends PanelContainer

@onready var label_brush_size = $Tools/LabelBrushSize
@onready var redo_button = $Tools/HBoxContainer/RedoButton

func _on_h_scroll_brush_size_value_changed(value):
	label_brush_size.text = "Brush size: " + str(value) + "px"


func _on_added_to_redo():
	if redo_button.disabled:
		redo_button.disabled = false


func _on_emptied_redo():
	if !redo_button.disabled:
		redo_button.disabled = true
