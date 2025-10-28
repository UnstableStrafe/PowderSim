extends Area2D
class_name Particle

@export var id: String
@export var world: World

@onready var left_detector: Area2D = $LeftDetector
@onready var right_detector: Area2D = $RightDetector
@onready var top_detector: Area2D = $TopDetector
@onready var bottom_detector: Area2D = $BottomDetector

var surrounded: bool:
	get = get_is_surrounded
# if a particle's left, right, top, and bottom detectors are colliding, disable this particle's logic

var tile_pos: Vector2i:
	get:
		return world.convert_particle_coords_to_tile(global_position)

func _ready() -> void:
	if world:
		mouse_entered.connect(_mouse_entered_body)
		mouse_exited.connect(_mouse_exited_body)

		world.mark_tile_as_occupied(global_position)

func get_is_surrounded() -> bool:
	var f_left: bool = get_if_area_colliding(left_detector)
	var f_right: bool = get_if_area_colliding(right_detector)
	var f_top: bool = get_if_area_colliding(top_detector)
	var f_bottom: bool = get_if_area_colliding(bottom_detector)
	
	if f_left and f_right and f_top and f_bottom:
		return true
	else:
		return false

func get_if_area_colliding(area: Area2D) -> bool:
	if area.has_overlapping_areas():
		return true
	elif area.has_overlapping_bodies():
		return true
	else:
		return false

func _mouse_entered_body() -> void:
	get_tree().get_first_node_in_group("MaterialInfo").text = id.capitalize()

func _mouse_exited_body() -> void:
	get_tree().get_first_node_in_group("MaterialInfo").text = ""
