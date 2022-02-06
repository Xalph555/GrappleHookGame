#--------------------------------------#
# Replacable Tiles Script              #
#--------------------------------------#
extends TileMap


# Variables:
#---------------------------------------
export(Array, String) var tile_names
export(Array, PackedScene) var objects_to_instance

onready var cell_x = cell_size.x
onready var cell_y = cell_size.y


# Functions:
#---------------------------------------
func _ready() -> void:
	assert(len(tile_names) == len(objects_to_instance), 
			"Not enough tile_names for every objects_to_instance or vice versa.")
	
	for i in range(len(tile_names)):
		var tile_positions = get_used_cells_by_id(tile_set.find_tile_by_name(tile_names[i]))
		
		for tile_pos in tile_positions:
			var object_instance = objects_to_instance[i].instance()
			
			var pos = map_to_world(tile_pos)
			pos.x += cell_x * 0.5
			pos.y += cell_y * 0.5
			
			object_instance.position = pos
			
			add_child(object_instance)
			
			# remove the existing tile
			set_cell(tile_pos.x, tile_pos.y, -1)
