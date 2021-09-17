extends KinematicBody2D

var move_speed := 6000

var pull_x := 10
var pull_y := 250
var hook_pull := Vector2(pull_x, pull_y)

var move_dir := Vector2.ZERO
var hook_dir := Vector2.ZERO
var velocity := Vector2.ZERO
const TENSION_MULT := 10
var gravity := 40

var is_hooked := false

var parent: KinematicBody2D

onready var hook_chain := $Chain


func _ready() -> void:
	pass


func display_chain(delta):
	var distance_to_parent := self.global_position.distance_to(parent.global_position)
	
	# chain graphics
	hook_chain.region_rect.size.y = distance_to_parent
	hook_chain.rotation = self.position.angle_to_point(parent.global_position) - self.rotation + deg2rad(90)


func apply_tension(delta):
	hook_dir = (self.global_position - parent.global_position).normalized()
	
	var grav = Vector2(0, gravity)
	var tension_vec := hook_dir * abs(hook_dir.dot(grav)) * TENSION_MULT
	
	parent.velocity += tension_vec
		

func fly_hook(delta):
	velocity = move_dir * move_speed * delta

	if move_and_collide(velocity):
		is_hooked = true
		move_dir = Vector2.ZERO
		hook_chain.visible = true
		

func _physics_process(delta: float) -> void:
	display_chain(delta)
	
	if is_hooked:
		apply_tension(delta)
	else:
		fly_hook(delta)


func init(shooter: KinematicBody2D, dir: Vector2) -> void:
	parent = shooter
	position = parent.global_position
	
	move_dir = dir
	rotation = dir.angle()
	
	is_hooked = false


func release() -> void:
	queue_free()
