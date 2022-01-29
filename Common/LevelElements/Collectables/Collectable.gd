#--------------------------------------#
# Collectable Script                   #
#--------------------------------------#
extends Area2D

class_name Collectable


# Functions:
#---------------------------------------
func _ready() -> void:
	self.connect("body_entered", self, "_on_body_entered")


func on_entered(body: Node) -> void:
	pass


func _on_body_entered(body: Node) -> void:
	on_entered(body)
