extends KinematicBody2D

var move_speed := 6000

var pull_x := 10
var pull_y := 250
var hook_pull := Vector2(pull_x, pull_y)

var move_dir := Vector2.ZERO
var hook_dir := Vector2.ZERO
var velocity := Vector2.ZERO
var start_dir := Vector2.ZERO
var orignal_dist := 0.0

var is_hooked := false

var parent: KinematicBody2D

onready var hook_chain := $Chain


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	var distance_to_parent := self.global_position.distance_to(parent.global_position)
	
	# chain graphics
	hook_chain.region_rect.size.y = distance_to_parent
	hook_chain.rotation = self.position.angle_to_point(parent.global_position) - self.rotation + deg2rad(90)
	
	hook_dir = (self.global_position - parent.global_position).normalized()
	
	if is_hooked:
		parent.is_flying = true
		
		# adjusting pull direction
		if hook_dir.y < 0:
			hook_pull.y = -abs(hook_pull.y)
		else:
			hook_pull.y = abs(hook_pull.y)

		if hook_dir.x < 0:
			hook_pull.x = -abs(hook_pull.x)
		else:
			hook_pull.x = abs(hook_pull.x)
		
		var tension_vec := hook_dir * hook_dir.dot(hook_pull)
		
		# dead space
		var dead_space := 150.00
		if distance_to_parent < dead_space:
			tension_vec *= 0.32
		
		parent.velocity += tension_vec 
		
		print(distance_to_parent)
		
	else:
		velocity = move_dir * move_speed * delta
		
		if move_and_collide(velocity):
			is_hooked = true
			move_dir = Vector2.ZERO
			hook_chain.visible = true
			start_dir = hook_dir
			orignal_dist = distance_to_parent


func shoot(shooter: KinematicBody2D, dir: Vector2) -> void:
	parent = shooter
	position = parent.global_position
	
	move_dir = dir
	rotation = dir.angle()
	
	is_hooked = false


func release() -> void:
	queue_free()
