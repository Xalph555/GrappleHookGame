extends KinematicBody2D


var gravity := 100
var jump_height := -1500
var move_speed := 550

var input_dir := Vector2.ZERO
var velocity := Vector2.ZERO

onready var hook = $Hook


func _ready() -> void:
	pass 


func _input(event) -> void:
	pass
		

func _physics_process(delta) -> void:
	velocity.y += gravity
	
	# Run
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir = input_dir.normalized()
	
	# Jump
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y += jump_height
	
	# Shoot hook
	if Input.is_mouse_button_pressed(1):
		hook.shoot(get_global_mouse_position() - self.global_position)
	
	velocity.x = move_speed * input_dir.x
	velocity = move_and_slide(velocity, Vector2.UP)
