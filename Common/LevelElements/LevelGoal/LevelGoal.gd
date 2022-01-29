#--------------------------------------#
# LevelGoal Script                     #
#--------------------------------------#
extends StaticBody2D

class_name LevelGoal



# Functions:
#---------------------------------------
func _ready() -> void:
	pass


func _on_Area2D_body_entered(body: Node) -> void:
	GameEvents.emit_signal("level_complete")
	
	print("Player has completed the level!")
