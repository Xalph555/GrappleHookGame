extends KinematicBody2D

var move_speed := 1800

var pull_x := 100
var pull_y := 100

var direction := Vector2.ZERO
var velocity := Vector2.ZERO

var parent: KinematicBody2D

var is_hooked := false

#var line: Line2D


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	
	if is_hooked:
		if parent.global_position.y >= self.global_position.y:
			parent.velocity.y -= pull_y
			#print("attempting to pull up")
		
		if parent.global_position.y < self.global_position.y:
			parent.velocity.y += pull_y
			#print("attempting to pull down")
		
		if parent.global_position.x >= self.global_position.x:
			parent.velocity.x -= pull_x
			#print("attempting to pull left")

		if parent.global_position.x < self.global_position.x:
			parent.velocity.x += pull_x
			#print("attempting to pull right")
	
	else:
		velocity = direction * move_speed * delta
	
#		if line.points:
#			line.points[-1] = parent.global_position
		
		if move_and_collide(velocity):
			is_hooked = true
			direction = Vector2.ZERO
			


func shoot(shooter: KinematicBody2D, dir: Vector2) -> void:
	
	
#	line = Line2D.new()
#	add_child(line)
#
#	line.add_point(self.global_position)
#	line.add_point(to_local(parent.global_position))

	parent = shooter
	position = parent.global_position
	
	direction = dir
	rotation = dir.angle()
	
	is_hooked = false


func release() -> void:
	queue_free()
