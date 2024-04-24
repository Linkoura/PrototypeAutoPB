extends PanelContainer

@onready var label_brush_size = $Tools/LabelBrushSize

func _on_h_scroll_brush_size_value_changed(value):
	label_brush_size.text = "Brush size: " + str(value) + "px"

