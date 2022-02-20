#--------------------------------------#
# Level Manager Script                 #
#--------------------------------------#
extends Node2D


# Signals:
#---------------------------------------



# Variables:
#---------------------------------------



# Functions:
#---------------------------------------
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reload_level"):
		reload_level()


func reload_level() -> void:
	get_tree().reload_current_scene()
	PlayerStats.reload_stats()
