extends RigidBody2D

class_name Projectile

export(Vector2) var projectile_offeset = Vector2(0, 0)

export (float) var gravity = 1000

var hasCollided := false


func _ready() -> void:
	pass


#func throw_projectile(pos: Vector2, dir: Vector2, force: float) -> void:
#	self.global_position = pos
#	apply_impulse(projectile_offeset, dir * force)


func _on_body_entered(body: Node) -> void:
	if !hasCollided:
		hasCollided = true
		$ShortTime.start()


func _on_ShortTime_timeout() -> void:
	queue_free()


func _on_LifeTime_timeout() -> void:
	queue_free()
