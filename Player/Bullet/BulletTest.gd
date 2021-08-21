extends KinematicBody2D


var direction := Vector2.ZERO
var move_speed := 800
var velocity := Vector2.ZERO


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	velocity = direction * move_speed
	velocity = move_and_slide(velocity)


func shoot(dir, start_pos) -> void:
	dir.normalized()
	direction = dir
	self.position = start_pos
