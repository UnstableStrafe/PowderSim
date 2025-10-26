extends Particle


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	world.mark_tile_as_occupied(global_position)
