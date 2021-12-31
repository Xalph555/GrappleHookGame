extends Area2D


onready var collision_shape := $CollisionShape2D


func disable_hurt_box() -> void:
	collision_shape.disabled = true


func enable_hurt_box() -> void:
	collision_shape.disabled = false
