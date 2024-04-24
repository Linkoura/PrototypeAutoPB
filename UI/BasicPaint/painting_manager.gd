extends Control

class Stroke:
	var brush_color : Color
	var brush_size : int
	var stroke_points := []
	
	func _init(point, color: Color, size: int):
		self.stroke_points = []
		self.stroke_points.append(point)
		self.brush_color = color
		self.brush_size = size

@onready var save_file_dialog = $SaveFileDialog
@onready var drawing_area_bg = $MainContainer/HBoxContainer/DrawingAreaBG
var brush_color := Color.BLACK
var brush_size := 32

var stroke_list : Array[Stroke] = []

signal draw_request(strokelist)

var left_mouse_pressed := false
#var drawing_area_rect : Rect2

func _ready() -> void:
	save_file_dialog.file_selected.connect(self.save_picture)

func _process(_delta) -> void:
	if left_mouse_pressed:
		if stroke_list.is_empty():
			return
		var mouse_pos = get_viewport().get_mouse_position()
		# Check if the mouse is currently inside the canvas/drawing-area.
		var drawing_area_rect := Rect2(drawing_area_bg.global_position, drawing_area_bg.size)
		if drawing_area_rect.has_point(mouse_pos):
			stroke_list[-1].stroke_points.append(drawing_area_bg.get_global_transform().affine_inverse() * mouse_pos)
			draw_request.emit(stroke_list)

func _gui_input(event) -> void:
	if !(event is InputEventMouseButton) or event is InputEventMouseMotion:
		return
	if !(event.button_index == MOUSE_BUTTON_LEFT):
		return
	if event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		# Check if the mouse is currently inside the canvas/drawing-area.
		var drawing_area_rect := Rect2(drawing_area_bg.global_position, drawing_area_bg.size)
		if drawing_area_rect.has_point(mouse_pos):
			left_mouse_pressed = true
			stroke_list.append(Stroke.new(drawing_area_bg.get_global_transform().affine_inverse() * mouse_pos, brush_color, brush_size))
			draw_request.emit(stroke_list)
	elif not event.pressed:
		left_mouse_pressed = false

func _on_undo_button_pressed() -> void:
	if stroke_list.is_empty():
		return
	stroke_list.remove_at(stroke_list.size() - 1)
	draw_request.emit(stroke_list)


func _on_clear_button_pressed() -> void:
	stroke_list.clear()
	draw_request.emit(stroke_list)


func _on_save_button_pressed() -> void:
	save_file_dialog.popup_centered()

func save_picture(path):
	# Wait until the frame has finished before getting the texture.
	await RenderingServer.frame_post_draw

	# Get the viewport image.
	var img = get_viewport().get_texture().get_image()
	# Crop the image so we only have canvas area.
	var cropped_image = img.get_region(Rect2(drawing_area_bg.global_position, drawing_area_bg.size))

	# Save the image with the passed in path we got from the save dialog.
	cropped_image.save_png(path)

func _on_color_picker_button_color_changed(color) -> void:
	brush_color = color


func _on_h_scroll_brush_size_value_changed(value) -> void:
	brush_size = ceil(value)
