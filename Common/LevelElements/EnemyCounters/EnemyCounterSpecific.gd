#--------------------------------------#
# Enemy Counter Specific Script        #
#--------------------------------------#
extends EnemyCounterBase

class_name EnemyCounterSpecific


# Variables:
#---------------------------------------
export(Array, NodePath) var enemy_paths


# Functions:
#---------------------------------------
func _ready() -> void:
	yield(get_tree(), "idle_frame")
	
	if enemy_paths.size() <= 0:
		return
	
	# get all assigned enemy references
	var enemies_temp : Array
	
	for path in enemy_paths:
		enemies_temp.append(get_node(path))
	
	set_enemies(enemies_temp)
