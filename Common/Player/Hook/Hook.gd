#--------------------------------------#
# Grapple Hook Script                  #
#--------------------------------------#

extends KinematicBody2D

# Variables
#---------------------------------------
var move_speed := 6000

var pull_x := 50
var pull_y := 280
var hook_pull := Vector2(pull_x, pull_y)

var move_dir := Vector2.ZERO
var hook_dir := Vector2.ZERO
var velocity := Vector2.ZERO

var distance_to_parent := 0.0

var is_hooked := false

var parent: KinematicBody2D

onready var hook_chain := $Chain



# Functions:
#---------------------------------------
func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	distance_to_parent = self.global_position.distance_to(parent.global_position)
	hook_dir = (self.global_position - parent.global_position).normalized()
	
	display_chain()
	
	if is_hooked:
		apply_tension()
	
	else:
		fly_hook(delta)


func display_chain():
	# chain graphics
	hook_chain.region_rect.size.y = distance_to_parent
	hook_chain.rotation = self.position.angle_to_point(parent.global_position) - self.rotation + deg2rad(90)


func apply_tension():
	parent.is_flying = true
	
	# adjusting pull direction
	hook_pull.x = sign(hook_dir.x) * abs(hook_pull.x)
	hook_pull.y = sign(hook_dir.y) * abs(hook_pull.y)

	var tension_vec := hook_dir * hook_dir.dot(hook_pull)
	
	# dead space
	var dead_space := 150.00
	if distance_to_parent < dead_space:
		tension_vec *= 0.002 * (pull_x + pull_y)/2
	
	parent.limit_speed = parent.max_speed * 3.5
	#parent.limit_speed_y = parent.max_speed_y * 1.5
	parent.velocity += tension_vec 


func fly_hook(delta: float):
	velocity = move_dir * move_speed * delta
		
	if move_and_collide(velocity):
		is_hooked = true
		move_dir = Vector2.ZERO


func shoot(shooter: KinematicBody2D, dir: Vector2) -> void:
	parent = shooter
	position = parent.global_position
	
	move_dir = dir
	rotation = dir.angle()
	
	is_hooked = false


func release() -> void:
	queue_free()
