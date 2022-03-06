#--------------------------------------#
# Replacable Tiles Script              #
#--------------------------------------#
extends TileMap


# Variables:
#---------------------------------------
export(Array, PackedScene) var spike


# Functions:
#---------------------------------------
func _ready() -> void:
	replace_tiles_with_spikes()


func replace_tiles_with_spikes() -> void:
	var cell_x = cell_size.x
	var cell_y = cell_size.y
	
	for tile_pos in get_used_cells_by_id(tile_set.find_tile_by_name("Spikes")):
		var spike_instance = spike.instance()
		
		var pos = map_to_world(tile_pos)
		pos.x += cell_x * 0.5
		pos.y += cell_y * 0.5
		
		spike_instance.position = pos
		
		add_child(spike_instance)
		
		# remove the existing tile
		set_cell(tile_pos.x, tile_pos.y, -1)
