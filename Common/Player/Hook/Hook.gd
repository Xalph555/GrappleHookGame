extends KinematicBody2D

var move_speed := 6000

var pull_x_max := 5
var pull_y_max := 5
var hook_pull := Vector2(pull_x_max, pull_y_max)

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
	
	hook_chain.region_rect.size.y = distance_to_parent
	hook_chain.rotation = self.position.angle_to_point(parent.global_position) - self.rotation + deg2rad(90)
	
	hook_dir = self.global_position - parent.global_position
	
	if is_hooked:
		parent.is_flying = true
		
		hook_chain.region_rect.size.y = distance_to_parent
		hook_chain.rotation = self.position.angle_to_point(parent.global_position) - self.rotation + deg2rad(90)
		
#		if sign(hook_dir.x) != sign(start_dir.x):
#			hook_pull.x *= 0.1
#
#		else:
#			hook_pull.x *= 1.8
#
#		if sign(hook_dir.y) != sign(start_dir.y):d
#			hook_pull.y *= 0.1 
#
#		else:
#			hook_pull.y *= 1.3
		
		#hook_pull.x = clamp(hook_pull.x , pull_x_max * 0.01, pull_x_max)
		#hook_pull.y = clamp(hook_pull.y, pull_y_max * 0.01, pull_y_max)
		
		var player_to_hook = parent.global_position - self.global_position
		
		parent.velocity += (player_to_hook.normalized() * player_to_hook.normalized().dot(Vector2(10, -180))) #* hook_pull
		print(hook_pull)
		
		# another hook physics
		# 	move player in circular path with hook point as centre
		# 	may result 
		
		# stop pull from after half way mark - need to top hook_dir from updating
		# use tension vector that keeps player and hook point apart (essentially creating a circle)
	
		# maintain heavy pull force for the first second letting tension vector carry momentum 
		
	else:
		velocity = move_dir * move_speed * delta
		
		if move_and_collide(velocity):
			is_hooked = true
			move_dir = Vector2.ZERO
			hook_chain.visible = true
			start_dir = hook_dir
			orignal_dist = distance_to_parent
			
			#hook_dir = self.global_position - parent.global_position
			
			#pull_x *=  (abs(hook_dir.x / abs(distance_to_parent)))
			#pull_y *= (abs(hook_dir.y / abs(distance_to_parent)))
#
#			if abs(hook_dir.x) >= abs(hook_dir.y):
#				print("x-stronger")
#				print(pull_x)
#				print(pull_y)
#
#			else:
#				print("y-stronger")
#				print(pull_x)
#				print(pull_y)


func shoot(shooter: KinematicBody2D, dir: Vector2) -> void:
	parent = shooter
	position = parent.global_position
	
	move_dir = dir
	rotation = dir.angle()
	
	is_hooked = false


func release() -> void:
	queue_free()
