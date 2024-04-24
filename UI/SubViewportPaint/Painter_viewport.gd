extends Control

#This is just an enum to know what to do next, it's all managed in another script on my subviewportContainer
var draw_act : PaintManager.DRAW_ACTION = PaintManager.DRAW_ACTION.CLEAR

var strokes : Array[PaintManager.Stroke] = []
var redo_strokes : Array[PaintManager.Stroke] = []
var last_drawn_index : int = 0

func _draw() -> void:
	match draw_act:
		PaintManager.DRAW_ACTION.ADD:
			if strokes.is_empty():
				return
			var current_stroke = strokes[-1]
			var current_last_index = current_stroke.stroke_points.size() - 1
			for index in range(last_drawn_index, current_last_index):
				var point = current_stroke.stroke_points[index]
				draw_colored_polygon(generate_circle_polygon(current_stroke.brush_size / 2.0, 72, point), current_stroke.brush_color)
				if index > 0:
					if current_stroke.stroke_points[index - 1].distance_to(point) >= current_stroke.brush_size / 4.0:
						draw_line(current_stroke.stroke_points[index - 1], point, current_stroke.brush_color, current_stroke.brush_size, true)
			last_drawn_index = current_last_index
		PaintManager.DRAW_ACTION.UNDO:
			draw_rect(get_viewport_rect(),Color("ecb283"))
			if strokes.is_empty():
				return
			for stroke in strokes:
				if stroke.stroke_points.size() >= 1:
					var previous_pos := stroke.stroke_points[0] as Vector2
					for index in range(0,stroke.stroke_points.size() - 1):
						var point = stroke.stroke_points[index]
						draw_colored_polygon(generate_circle_polygon((stroke.brush_size) / 2.0, 72, point), stroke.brush_color)
						if previous_pos.distance_to(point) >= stroke.brush_size / 4.0:
							draw_line(previous_pos, point, stroke.brush_color, stroke.brush_size, true)
						previous_pos = point
			draw_act = PaintManager.DRAW_ACTION.ADD
		PaintManager.DRAW_ACTION.CLEAR:
			draw_rect(get_viewport_rect(),Color("ecb283"))
			draw_act = PaintManager.DRAW_ACTION.ADD

func generate_circle_polygon(radius: float, num_sides: int, pos: Vector2) -> PackedVector2Array:
	var angle_delta: float = (PI * 2) / num_sides
	var vector: Vector2 = Vector2(radius, 0)
	var polygon: PackedVector2Array = []

	for _i in num_sides:
		polygon.append(vector + pos)
		vector = vector.rotated(angle_delta)

	return polygon
