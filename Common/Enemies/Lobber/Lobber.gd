extends KinematicBody2D

export(PackedScene) var projectile = projectile as Projectile
export(float) var throwing_force = 1000.0

var target : KinematicBody2D
var dir_to_target: Vector2

onready var throw_delay = $ThrowDelay


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if target:
		dir_to_target = (target.global_position - self.global_position).normalized()


func _on_ThrowDelay_timeout() -> void:
	var _projectile = projectile.instance()
	get_viewport().add_child(_projectile) # not sure if spawning on viewport is good idea
	
	#_projectile.throw_projectile(self.global_position, dir_to_target, throwing_force)
	_projectile.transform = self.global_transform
	_projectile.velocity = _projectile.transform.x * 100
	
	throw_delay.start()


func _on_AttackRange_body_entered(body: Node) -> void:
	target = body as KinematicBody2D
	throw_delay.start()


func _on_AttackRange_body_exited(body: Node) -> void:
	if body is KinematicBody2D:
		target = null
		throw_delay.stop()
