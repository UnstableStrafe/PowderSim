extends Area2D
class_name Tile

var empty : bool = true

func _on_area_entered(area: Area2D) -> void:
	empty = false

func _on_area_exited(area: Area2D) -> void:
	empty = true
