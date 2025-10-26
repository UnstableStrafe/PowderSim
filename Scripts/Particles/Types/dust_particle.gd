extends Particle
class_name DustParticle

# Dust particles have the following movement logic:
# If nothing below, move down;
# Elif nothing to down-left and left, move left;
# Elif nothing to down-right and right, move right;
# Else, do nothing

@onready var bl_detector: Area2D = $BLDetector
@onready var br_detector: Area2D = $BRDetector

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !surrounded: 
		if !get_is_surrounded():
			_move()

func _move() -> void:
	if !get_if_area_colliding(bottom_detector):
		world.mark_tile_as_empty(global_position)
		position.y += 10
		world.mark_tile_as_occupied(global_position)
	elif !get_if_area_colliding(left_detector) and !get_if_area_colliding(bl_detector):
		world.mark_tile_as_empty(global_position)
		position.x -= 10
		world.mark_tile_as_occupied(global_position)
	elif !get_if_area_colliding(right_detector) and !get_if_area_colliding(br_detector):
		world.mark_tile_as_empty(global_position)
		position.x += 10
		world.mark_tile_as_occupied(global_position)
