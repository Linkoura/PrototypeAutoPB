extends SubViewportContainer
class_name PaintManager

class Stroke:
	var brush_color : Color
	var brush_size : int
	var stroke_points := []
	
	func _init(point, color: Color, size: int):
		self.stroke_points = []
		self.stroke_points.append(point)
		self.brush_color = color
		self.brush_size = size

signal added_to_redo()
signal emptied_redo()

@onready var sub_viewport = $SubViewport
@onready var painter = $SubViewport/Painter

var brush_color := Color.BLACK
var brush_size := 32

enum DRAW_ACTION {ADD, UNDO, CLEAR}

var ongoing_stroke : bool = false
var left_mouse_pressed := false
var mouse_inside_rect := false
var mouse_started_inside := false

func _ready():
	sub_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE

func _process(_delta) -> void:
	if !left_mouse_pressed:
		return
	if !ongoing_stroke:
		return
	if !mouse_inside_rect:
		return
	if painter.strokes.is_empty():
		return
	if painter.strokes[-1].stroke_points.is_empty():
		return
	
	var mouse_pos = sub_viewport.get_mouse_position()
	# Check if the mouse is currently inside the canvas/drawing-area.
	if sub_viewport.get_visible_rect().has_point(mouse_pos):
		painter.strokes[-1].stroke_points.append(mouse_pos)
		painter.queue_redraw()

func _gui_input(event) -> void:
	if !(event is InputEventMouseButton) or (event is InputEventMouseMotion):
		return
	if !(event.button_index == MOUSE_BUTTON_LEFT):
		return
	if event.pressed:
		left_mouse_pressed = true
		#var mouse_pos = get_global_transform().affine_inverse() * viewport.get_mouse_position()
		var mouse_pos = sub_viewport.get_mouse_position()
		# Check if the mouse is currently inside the canvas/drawing-area.
		if sub_viewport.get_visible_rect().has_point(mouse_pos):
			mouse_started_inside = true
			ongoing_stroke = true
			painter.redo_strokes.clear()
			emptied_redo.emit()
			painter.strokes.append(Stroke.new(mouse_pos, brush_color, brush_size))
			painter.queue_redraw()
	elif not event.pressed:
		left_mouse_pressed = false
		ongoing_stroke = false
		mouse_started_inside = false
		painter.last_drawn_index = 0

func _on_redo_button_pressed() -> void:
	if painter.redo_strokes.is_empty() or ongoing_stroke:
		return
	painter.strokes.append(painter.redo_strokes.pop_back())
	painter.last_drawn_index = 0
	if painter.redo_strokes.is_empty():
		emptied_redo.emit()
	painter.queue_redraw()

func _on_undo_button_pressed() -> void:
	if painter.strokes.is_empty() or ongoing_stroke:
		return
	painter.redo_strokes.append(painter.strokes.pop_back())
	added_to_redo.emit()
	painter.draw_act = DRAW_ACTION.UNDO
	#viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	RenderingServer.viewport_set_clear_mode(sub_viewport.get_viewport_rid(), RenderingServer.VIEWPORT_CLEAR_ONLY_NEXT_FRAME)
	painter.queue_redraw()

func _on_clear_button_pressed() -> void:
	painter.strokes.clear()
	painter.redo_strokes.clear()
	emptied_redo.emit()
	painter.last_drawn_index = 0
	painter.draw_act = DRAW_ACTION.CLEAR
	RenderingServer.viewport_set_clear_mode(sub_viewport.get_viewport_rid(), RenderingServer.VIEWPORT_CLEAR_ONLY_NEXT_FRAME)
	painter.queue_redraw()

func save_picture(path):
	# Wait until the frame has finished before getting the texture.
	await RenderingServer.frame_post_draw

	# Get the viewport image.
	var img = sub_viewport.get_texture().get_image()
	# Crop the image so we only have canvas area.
	var cropped_image = img.get_region(sub_viewport.get_visible_rect())#Rect2(global_position, size))

	# Save the image with the passed in path we got from the save dialog.
	cropped_image.save_png(path)

func _on_color_picker_button_color_changed(color) -> void:
	brush_color = color

func _on_h_scroll_brush_size_value_changed(value) -> void:
	brush_size = value

func _on_mouse_entered():
	mouse_inside_rect = true
	if (left_mouse_pressed and mouse_started_inside):
		ongoing_stroke = true
		var mouse_pos = sub_viewport.get_mouse_position()
		painter.strokes.append(Stroke.new(mouse_pos, brush_color, brush_size))
		painter.queue_redraw()

func _on_mouse_exited():
	mouse_inside_rect = false
	ongoing_stroke = false
	painter.last_drawn_index = 0
