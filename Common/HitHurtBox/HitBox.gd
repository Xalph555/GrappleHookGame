extends Area2D

export(float) var damage = 0
export(float) var knock_back_force = 0

onready var collision_shape := $CollisionShape2D


func disable_hit_box() -> void:
	collision_shape.disabled = true


func enable_hit_box() -> void:
	collision_shape.disabled = false