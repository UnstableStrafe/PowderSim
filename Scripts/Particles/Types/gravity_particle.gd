extends Particle
class_name GravityParticle

# GravityParticles simply move downwards if they can.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void: 
	if !get_is_surrounded():
		_move()
	
func _move() -> void:
	if !get_if_area_colliding(bottom_detector):
		world.mark_tile_as_empty(global_position)
		position.y += 10
		world.mark_tile_as_occupied(global_position)
