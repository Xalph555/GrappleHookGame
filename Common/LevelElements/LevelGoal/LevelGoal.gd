#--------------------------------------#
# LevelGoal Script                     #
#--------------------------------------#
extends Area2D

class_name LevelGoal



# Functions:
#---------------------------------------
func _ready() -> void:
	pass


func _on_body_entered(body: Node) -> void:
	print("Player has completed the level!")
