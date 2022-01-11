#--------------------------------------#
# Line2DTrail Script                   #
#--------------------------------------#
extends Line2D

class_name Line2DTrail


# Variables:
#---------------------------------------
export var length := 30

var _point : Vector2


# Functions:
#---------------------------------------
func _process(delta: float) -> void:
	global_position = Vector2.ZERO
	
	_point = get_parent().global_position
	
	add_point(_point)
	
	while get_point_count() > length:
		remove_point(0)
