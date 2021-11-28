extends RigidBody2D

class_name Projectile

export(Vector2) var projectile_offeset = Vector2(0, 0)


func _ready() -> void:
	pass


func throw_projectile(pos: Vector2, dir: Vector2, force: float) -> void:
	self.global_position = pos
	apply_impulse(projectile_offeset, dir * force)
