extends KinematicBody2D

var move_speed := 3000

var pull_x := 300
var pull_y := 300

var move_dir := Vector2.ZERO
var hook_dir := Vector2.ZERO
var velocity := Vector2.ZERO

var is_hooked := false

var parent: KinematicBody2D

#var line: Line2D


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if is_hooked:
		
		parent.is_flying = true
		
		if parent.global_position.y >= self.global_position.y:
			parent.velocity.y -= pull_y
		
		if parent.global_position.y < self.global_position.y:
			parent.velocity.y += pull_y
		
		if parent.global_position.x >= self.global_position.x:
			parent.velocity.x -= pull_x

		if parent.global_position.x < self.global_position.x:
			parent.velocity.x += pull_x
	
	else:
		velocity = move_dir * move_speed * delta
	
#		if line.points:
#			line.points[-1] = parent.global_position
		
		if move_and_collide(velocity):
			is_hooked = true
			move_dir = Vector2.ZERO
			
			hook_dir = parent.global_position - self.global_position
			
			if abs(hook_dir.x) >= abs(hook_dir.y):
				pull_x *= (abs(hook_dir.x) / abs(parent.global_position.distance_to(self.global_position)))
				pull_y *= (abs(hook_dir.y) / abs(parent.global_position.distance_to(self.global_position)))
				
				print("x-stronger")
				print(pull_x)
				print(pull_y)
			
			else:
				pull_x *= (abs(hook_dir.x) / abs(parent.global_position.distance_to(self.global_position)))
				pull_y *= (abs(hook_dir.y) / abs(parent.global_position.distance_to(self.global_position)))
				
				print("y-stronger")
				print(pull_x)
				print(pull_y)

func shoot(shooter: KinematicBody2D, dir: Vector2) -> void:
	
	
#	line = Line2D.new()
#	add_child(line)
#
#	line.add_point(self.global_position)
#	line.add_point(to_local(parent.global_position))

	parent = shooter
	position = parent.global_position
	
	move_dir = dir
	rotation = dir.angle()
	
	is_hooked = false


func release() -> void:
	queue_free()
