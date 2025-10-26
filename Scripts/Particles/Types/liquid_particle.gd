extends Particle
class_name LiquidParticle


# Liquid particles have the following movement logic:
# If nothing below, move down;
# Elif try to move to the lowest tile it can reach

enum DIRECTIONS {NULL, LEFT, RIGHT}

var target_tile_direction := DIRECTIONS.NULL
# just so its easier to keep track of the direction to the target tile.
# NULL is used when there is no target tile.

var frames_since_last_tile_check : int = 0
# so it doesnt check every frame for an open tile
var on_check_cooldown : bool = false

@onready var bl_detector: Area2D = $BLDetector
@onready var br_detector: Area2D = $BRDetector

var target_tile : Vector2i = Vector2i(-1111, -1111)
# (-1111, -1111) is used as a null value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !surrounded: 
		if !get_is_surrounded():
			move()

func move() -> void:
	if on_check_cooldown == true:
		frames_since_last_tile_check += 1

	if frames_since_last_tile_check >= 8:
		frames_since_last_tile_check = 0
		on_check_cooldown = false
	
	if !get_if_area_colliding(bottom_detector):
		#world.mark_tile_as_empty(global_position)
		print(world.convert_particle_coords_to_tile(global_position))
		position.y += 10
		print(world.convert_particle_coords_to_tile(global_position))
		#world.mark_tile_as_occupied(global_position)
		
	# fix this logic later: maybe use an OR statement?
	elif !get_if_area_colliding(left_detector) and !get_if_area_colliding(right_detector):
		var pos_t = world.convert_particle_coords_to_tile(global_position)
		var t_d = world.tile_map_layer.get_cell_tile_data(Vector2i(pos_t.x, pos_t.y + 1))
		if t_d.get_custom_data("border") == false:
			# Do not check for target tiles if the left and right detectors are colliding 
			# and the bottom collider is detecting the world border
			if target_tile != Vector2i(-1111, -1111):
				match target_tile_direction:
					DIRECTIONS.LEFT:
						world.mark_tile_as_empty(global_position)
						position.x -= 10
						world.mark_tile_as_occupied(global_position)
					DIRECTIONS.RIGHT:
						world.mark_tile_as_empty(global_position)
						position.x += 10
						world.mark_tile_as_occupied(global_position)
					_:
						print("how the fuck is this printing")
						
				if world.convert_particle_coords_to_tile(global_position) == target_tile:
					target_tile = Vector2i(-1111, -1111)
					target_tile_direction = DIRECTIONS.NULL
					on_check_cooldown = true
					#rest when the tile is found
			elif frames_since_last_tile_check == 0:
				find_target_tile()
				
				# if there is no target tile, find one. if one is not found, wait a few frames before searching again
				
				# if target tile is no longer empty, find a new one



# THE FUCKING ISSUE IS IN HERE SOMEWHERE FUCKING KILL ME PLEASE AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
# :) 
func find_target_tile():
	# find the particle's tile location
	var particle_tile_pos : Vector2i = world.convert_particle_coords_to_tile(global_position)
	var left_tile_pos = Vector2i(particle_tile_pos.x - 1, particle_tile_pos.y)
	var right_tile_pos = Vector2i(particle_tile_pos.x + 1, particle_tile_pos.y)
	var hit_left_border : bool = false
	var hit_right_border : bool = true
	
	# left moves in negative direction
	# right moves in positive direction
	# find a tile to the left first, then find on on the right.
	# if a border tile is found, stop searching on that side.
	
	var loops : int = 0
	while (target_tile == Vector2i(-1111, -1111) or (hit_left_border == true and hit_right_border == true)):
		if loops >= 100:
			break
		if hit_left_border == false:
			
			hit_left_border = check_left(left_tile_pos)
			#print(left_tile_pos)
			if target_tile != Vector2i(-1111, -1111): #if a tile found, break
				break
			else:
				left_tile_pos.x -= 1
		loops += 1

# returns if the world border has been hit
func check_left(tile_pos : Vector2i) -> bool:

	var tile_data = world.tile_map_layer.get_cell_tile_data(tile_pos)
	if tile_data.get_custom_data("border") == true:
		return true
	else:
		#print(tile_data.get_custom_data("empty"))
		# issue is here??
		if tile_data.get_custom_data("empty") == true:
			
			# check tile below
			var below_data = world.tile_map_layer.get_cell_tile_data(Vector2i(tile_pos.x, tile_pos.y + 1))
			if below_data.get_custom_data("empty") == true:
				target_tile = Vector2i(tile_pos.x, tile_pos.y)
				print(target_tile)
				target_tile_direction = DIRECTIONS.LEFT
	return false
