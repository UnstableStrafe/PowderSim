extends Marker2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target_pos_x = clampf(get_global_mouse_position().x, -get_viewport_rect().size.x / 2, get_viewport_rect().size.x / 2 - 100)
	var target_pos_y = clampf(get_global_mouse_position().y, -get_viewport_rect().size.y / 2 - 10, get_viewport_rect().size.y / 2 - 40)
	global_position = Vector2(target_pos_x, target_pos_y)
