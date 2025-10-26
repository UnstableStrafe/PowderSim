extends Node2D
class_name World

@onready var current_mat_label: Label = $Camera2D/Control/CurrentMatLabel
@onready var shape_cast: ShapeCast2D = $ShapeCast2D
@onready var erase_cast: ShapeCast2D = $EraseCast
@onready var tile_map_layer: TileMapLayer = $TileMapLayer

@export var particle_dictionary : Dictionary[String, PackedScene]
@export var current_material : String = "SAND"

#stored in tile coordinates. 
var tile_layers_dictionary : Dictionary[int, IntArrayHolder] # key is the y-level, value is the x-coord values

var can_bulk_place : bool = true
var can_bulk_erase : bool = false
var is_bulk_place_held : bool = false
var is_bulk_erase_held : bool = false

func _ready() -> void:
	current_mat_label.text = "Current Material: " + current_material.capitalize()
	#register_layers()

func register_layers() -> void:
	var tile_array : Array[Vector2i] = tile_map_layer.get_used_cells()
	
	#to convert tile coords to particle coords, multiply by 10, then add 5
	#to convert particle coords to tile coords, subtract 5, then divide by 10
	
	for i in tile_array:
		var int_array : IntArrayHolder = tile_layers_dictionary.get_or_add(i.y, IntArrayHolder.new())
		int_array.array.append(i.x)

	
func convert_tile_coords_to_particle(tile_coords : Vector2i) -> Vector2:
	var particle_coords = Vector2((tile_coords.x * 10) + 5, (tile_coords.y * 10) + 5)
	return particle_coords

func convert_particle_coords_to_tile(particle_coords : Vector2) -> Vector2i:
	var tile_coords = Vector2i((particle_coords.x - 5) / 10, (particle_coords.y - 5) / 10)
	return tile_coords

func get_tile_data(coordinates : Vector2) -> Variant:
	var tile_value : NullableBool = NullableBool.new()
	var tile_data = tile_map_layer.get_cell_tile_data(convert_particle_coords_to_tile(coordinates))
	if tile_data:
		tile_value.set_value_from_bool(tile_data.get_custom_data("empty"))
	else:
		tile_value.set_value(NullableBool.NBState.NULL)
	return tile_value.get_value() #The a tile should never not have an "empty" data layer but better to be safe?

func mark_tile_as_empty(coordinates : Vector2):
	var tile_data = tile_map_layer.get_cell_tile_data(convert_particle_coords_to_tile(coordinates))
	if tile_data:
		tile_data.set_custom_data("empty", true)

func mark_tile_as_occupied(coordinates : Vector2):
	var tile_data = tile_map_layer.get_cell_tile_data(convert_particle_coords_to_tile(coordinates))
	if tile_data:
		tile_data.set_custom_data("empty", false)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				place_particle()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				is_bulk_place_held = true
			else: 
				is_bulk_place_held = false
	elif event.is_action_pressed("erase"):
		erase_particle()

func _physics_process(delta: float) -> void:
	if can_bulk_place == true:
		if is_bulk_place_held == true:
			place_particle()
			can_bulk_place = false
			$PlacementCooldown.start()

func erase_particle() -> void:
	var pos = get_local_mouse_position()
	var new_x = snappedi(pos.x, 10)
	var delta_x = abs(new_x) - abs(pos.x)
	if delta_x == 0:
		delta_x = 5
	new_x = new_x + (sign(delta_x) * -5 * sign(pos.x))
	
	var new_y = snappedi(pos.y, 10)
	var delta_y = abs(new_y) - abs(pos.y)
	if delta_y == 0:
		delta_y = 5
	new_y = new_y + (sign(delta_y) * -5 * sign(pos.y))
	
	if new_x == 0:
		new_x = 5
	if new_y == 0:
		new_y = 5
	
	var new_pos = Vector2(new_x, new_y)
	
	new_pos.x = clampf(new_pos.x, -get_viewport_rect().size.x / 2 + 5, get_viewport_rect().size.x / 2 - 5)
	new_pos.y = clampf(new_pos.y,  -get_viewport_rect().size.y / 2 + 5, get_viewport_rect().size.y / 2 - 5)
	erase_cast.position = new_pos
	erase_cast.enabled = true
	erase_cast.force_shapecast_update()
	
	if erase_cast.is_colliding():
		for i in range(erase_cast.get_collision_count() - 1):
			erase_cast.get_collider(i).queue_free()
	
	erase_cast.enabled = false

func place_particle() -> void:
	var pos = get_local_mouse_position()
	var new_x = snappedi(pos.x, 10)
	var delta_x = abs(new_x) - abs(pos.x)
	if delta_x == 0:
		delta_x = 5
	new_x = new_x + (sign(delta_x) * -5 * sign(pos.x))
	
	var new_y = snappedi(pos.y, 10)
	var delta_y = abs(new_y) - abs(pos.y)
	if delta_y == 0:
		delta_y = 5
	new_y = new_y + (sign(delta_y) * -5 * sign(pos.y))
	
	if new_x == 0:
		new_x = 5
	if new_y == 0:
		new_y = 5
	
	var new_pos = Vector2(new_x, new_y)
	
	new_pos.x = clampf(new_pos.x, -get_viewport_rect().size.x / 2 + 5, get_viewport_rect().size.x / 2 - 5)
	new_pos.y = clampf(new_pos.y,  -get_viewport_rect().size.y / 2 + 5, get_viewport_rect().size.y / 2 - 5)
	
	shape_cast.position = new_pos
	shape_cast.enabled = true
	shape_cast.force_shapecast_update()
	if !shape_cast.is_colliding():
		var particle = particle_dictionary.get(current_material).instantiate()
		if particle == null:
			print("Chosen particle is NULL! Used Sand as a fallback")
			particle = particle_dictionary.get("SAND").instantiate()
		particle.world = $"."
		$Particles.add_child(particle)
		particle.position = new_pos
	
	shape_cast.enabled = false

func _on_placement_cooldown_timeout() -> void:
	can_bulk_place = true


func _on_erase_cooldown_timeout() -> void:
	can_bulk_erase = true
