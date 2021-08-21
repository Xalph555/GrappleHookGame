extends KinematicBody2D

var parent: KinematicBody2D

var move_speed := 1000

var direction := Vector2.ZERO
var velocity := Vector2.ZERO

var line: Line2D


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	velocity = direction * move_speed* delta
	
#	if line.points:
#		line.points[-1] = parent.global_position
	
	if move_and_collide(velocity):
		direction = Vector2.ZERO


func shoot(shooter: KinematicBody2D, dir: Vector2) -> void:
	parent = shooter
	
	line = Line2D.new()
	add_child(line)
	
	line.add_point(self.global_position)
	line.add_point(to_local(parent.global_position))
	
	position = parent.global_position
	
	direction = dir
	rotation = dir.angle()
