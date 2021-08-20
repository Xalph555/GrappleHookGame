extends KinematicBody2D

var move_speed = 1

var direction := Vector2.ZERO
var velocity := Vector2.ZERO


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	velocity = direction * move_speed * delta
	if move_and_collide(velocity):
		direction = Vector2.ZERO


func shoot(dir: Vector2) -> void:
	direction = dir
	look_at(dir)
	set_physics_process(true)
