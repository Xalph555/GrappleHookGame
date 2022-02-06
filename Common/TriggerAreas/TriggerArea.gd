#--------------------------------------#
# TriggerArea Script                   #
#--------------------------------------#
extends Area2D

class_name TriggerArea


# Variables:
#---------------------------------------
onready var _collision_shape := $CollisionShape2D


# Functions:
#---------------------------------------
func disable_trigger() -> void:
	_collision_shape.disabled = true


func enable_trigger() -> void:
	_collision_shape.disabled = false
