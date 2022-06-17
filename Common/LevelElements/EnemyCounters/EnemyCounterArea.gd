#--------------------------------------#
# Enemy Counter Area Script            #
#--------------------------------------#
extends EnemyCounterBase

class_name EnemyCounterArea


# Variables:
#---------------------------------------
onready var _detection_area := $Area2D


# Functions:
#---------------------------------------
func _ready() -> void:
	yield(get_tree(), "idle_frame")
	
	set_enemies(_detection_area.get_overlapping_bodies())
