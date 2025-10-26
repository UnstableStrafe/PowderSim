@tool
extends Control

@export var text_font : Font

@export var bg_color : Color = Color.WHITE
@export var line_color : Color = Color.BLACK

@export var outer_radius : int = 128
@export var inner_radius : int = 32
@export var line_width : int = 2
@export var text_size : int = 32

@export var text_offset = Vector2(16, 16)

@export var entries : Array[WheelOption] = []

var selected = 0

func _draw() -> void:
	draw_circle(Vector2.ZERO, outer_radius, bg_color, true, -1, true)
	draw_circle(Vector2.ZERO, inner_radius, line_color, true, -1, true)
	
	if len(entries) >= 2:
		# draw lines
		for i in range(len(entries)):
			# The angle to draw the segment to
			var rads = ((i + 1) * TAU) / len(entries)
			# The angle to start the segment from
			var start_rads = (TAU * i) / len(entries)
			var mid_rads = (rads + start_rads) / 2.0 * -1
			var radius_middle = (inner_radius + outer_radius) / 2.0
			var line_angle = Vector2.from_angle(rads)
			
			draw_line(line_angle * inner_radius, line_angle * outer_radius, line_color, line_width, true)
			
			var points_per_arc = 32
			var points_inner = PackedVector2Array()
			var points_outer = PackedVector2Array()
			
			for j in range(points_per_arc + 1):
				var angle = (start_rads + j * (rads - start_rads) / points_per_arc)
				points_inner.append(inner_radius * Vector2.from_angle(TAU - angle))
				points_outer.append(outer_radius * Vector2.from_angle(TAU - angle))
			
			points_outer.reverse()
			
			
			#var string_pos = (radius_middle * Vector2.from_angle((rads)).rotated(PI / len(entries))) - string_size / 2
			
			var mat_color = entries.get(i).material_color
			
			mat_color.a = 0.6
			
			if selected == i:
				
				mat_color.a = 1.0
				
				var string_size = text_font.get_string_size(entries.get(i).material_name.capitalize(), HORIZONTAL_ALIGNMENT_CENTER, -1, text_size)
				var string_pos = Vector2.ZERO - (string_size / 2)
				string_pos.y += 15
				draw_string(text_font, string_pos, entries.get(selected).material_name.capitalize(), HORIZONTAL_ALIGNMENT_CENTER, -1, text_size, Color.WHITE)
			
			draw_polygon(points_inner + points_outer, PackedColorArray([mat_color]))


func _process(delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	var mouse_radius = mouse_pos.length()
	
	if mouse_radius >= inner_radius:
		var mouse_rads = fposmod(mouse_pos.angle() * -1, TAU)
		selected = ceil((mouse_rads / TAU) * (len(entries))) - 1
		
		
	queue_redraw()
