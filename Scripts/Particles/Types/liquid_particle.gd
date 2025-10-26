extends Particle
class_name LiquidParticle

const MAX_CHECKS = 100
const NULL_VECTOR = Vector2i(-1111, -1111)

# Liquid particles have the following movement logic:
# If nothing below, move down;
# Elif try to move to the lowest tile it can reach

var target_tile: Vector2i = NULL_VECTOR
# (-1111, -1111) is used as a null value
var target_tile_direction := Vector2i.ZERO
# just so its easier to keep track of the direction to the target tile.
# NULL is used when there is no target tile.

var frames_since_last_tile_check: int = 0
# so it doesnt check every frame for an open tile
var on_check_cooldown: bool = false

@onready var bl_detector: Area2D = $BLDetector
@onready var br_detector: Area2D = $BRDetector

@onready var tile_size := world.tile_map_layer.tile_set.tile_size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
    if !surrounded:
        move()


func move() -> void:
    if on_check_cooldown == true:
        frames_since_last_tile_check += 1

    if frames_since_last_tile_check >= 8:
        frames_since_last_tile_check = 0
        on_check_cooldown = false

    # prints(
    #     tile_pos,
    #     "Left", can_move_in(Vector2i.LEFT),
    #     "Right", can_move_in(Vector2i.RIGHT),
    # )

    if can_move_in(Vector2i.DOWN):
        # print("Move down")
        move_in(Vector2i.DOWN)

        if tile_pos == target_tile:
            target_tile = NULL_VECTOR
            target_tile_direction = Vector2i.ZERO

    elif can_move_in(Vector2i.LEFT) or can_move_in(Vector2i.RIGHT):
        # Do not check for target tiles if the left and right detectors are colliding
        # and the bottom collider is detecting the world border
        if target_tile != NULL_VECTOR and can_move_in(target_tile_direction):
            move_in(target_tile_direction)

            if tile_pos == target_tile:
                target_tile = NULL_VECTOR
                target_tile_direction = Vector2i.ZERO
                #rest when the tile is found

        if frames_since_last_tile_check == 0:
            # print("find new target")
            find_target_tile()
            # print(target_tile)
            on_check_cooldown = true

            # if there is no target tile, find one. if one is not found, wait a few frames before searching again

            # if target tile is no longer empty, find a new one

# :)
func find_target_tile():
    # left moves in negative direction
    # right moves in positive direction
    # find a tile to the left first, then find on on the right.
    # if a border tile is found, stop searching on that side.
    for direction in [Vector2i.LEFT, Vector2i.RIGHT]:
        # Limit how far in each direction we will check
        for i in range(1, MAX_CHECKS + 1):
            var checking_pos: Vector2i = tile_pos + i * direction

            if can_move_to(checking_pos):
                # If tile below the current checked tile is empty
                if can_move_to(checking_pos + Vector2i.DOWN):
                    target_tile = checking_pos + Vector2i.DOWN
                    target_tile_direction = direction
                    # prints("Move towards", target_tile, "In", target_tile_direction)

                    return
            else:
                break

    # Set if no other tiles to move towards was found
    target_tile = NULL_VECTOR


func move_in(direction: Vector2i) -> void:
    # print("Move in", direction)
    world.mark_tile_as_empty(global_position)
    
    var target_pos := global_position + Vector2(tile_size * direction)
    world.mark_tile_as_occupied(target_pos)

    global_position = target_pos

func can_move_in(direction: Vector2i) -> bool:
    var _target_tile := tile_pos + direction
    # prints(_target_tile, can_move_to(_target_tile))
    return can_move_to(_target_tile)

func can_move_to(tile: Vector2i) -> bool:
    var tile_data := world.tile_map_layer.get_cell_tile_data(tile)
    if tile_data == null:
        return false

    return tile_data.get_custom_data(&"border") == false \
            and tile_data.get_custom_data(&"empty") == true
