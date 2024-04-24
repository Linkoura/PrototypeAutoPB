extends Panel

var stroke_list := []

func _on_draw_request(stroke_l):
	stroke_list = stroke_l
	queue_redraw()

func _draw() -> void:
	if stroke_list.is_empty():
		return
	for stroke in stroke_list:
		if stroke.stroke_points.size() >= 1:
			draw_colored_polygon(generate_circle_polygon(stroke.brush_size / 2.0, 72, stroke.stroke_points[0]), stroke.brush_color)
			#draw_circle(stroke.stroke_points[0], stroke.brush_size / 2.0, stroke.brush_color)
			if stroke.stroke_points.size() == 1:
				continue
			var previous_pos := stroke.stroke_points[0] as Vector2
			for point in stroke.stroke_points:
				draw_colored_polygon(generate_circle_polygon((stroke.brush_size) / 2.0, 72, point), stroke.brush_color)
				#draw_circle(point, stroke.brush_size / 2.0, stroke.brush_color)
				if previous_pos.distance_to(point) >= stroke.brush_size / 4:
					draw_line(previous_pos, point, stroke.brush_color, stroke.brush_size, true)
				previous_pos = point
			draw_colored_polygon(generate_circle_polygon(stroke.brush_size / 2.0, 72, stroke.stroke_points[-1]), stroke.brush_color)
			#draw_circle(stroke.stroke_points[-1], stroke.brush_size / 2.0, stroke.brush_color)

func generate_circle_polygon(radius: float, num_sides: int, pos: Vector2) -> PackedVector2Array:
	var angle_delta: float = (PI * 2) / num_sides
	var vector: Vector2 = Vector2(radius, 0)
	var polygon: PackedVector2Array = []

	for _i in num_sides:
		polygon.append(vector + pos)
		vector = vector.rotated(angle_delta)

	return polygon
