extends KinematicBody2D

const HOOK := preload("res://Common/Player/Hook/Hook.tscn")

var input_dir := Vector2.ZERO

var weight := 40
var jump_height := -1500
var move_speed := 580
#var acceleration = 50
var max_speed_x := 1000
var max_speed_y := 2000


var velocity := Vector2.ZERO

var can_grapple := true


func _ready() -> void:
	pass 


func _physics_process(delta) -> void:
	velocity.y += WorldGlobals.apply_gravity(weight)
	
	# Run
	
#	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
#	input_dir = input_dir.normalized()
#	velocity.x = move_speed * input_dir.x
	
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir = input_dir.normalized()

	velocity.x += (input_dir.x * move_speed)
	
	velocity.x = clamp(velocity.x, -max_speed_x, max_speed_x)
	velocity.y = clamp(velocity.y, -max_speed_y, max_speed_y)

	
	# Jump
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			velocity.y += jump_height
			
		velocity.x = lerp(velocity.x, 0, 0.1)
			
	else:
		velocity.y = lerp(velocity.y, 0, 0.005)
		velocity.x = lerp(velocity.x, 0, 0.005)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# Shoot hook
	if Input.is_action_just_pressed("ui_mouse_left") and can_grapple:
		can_grapple = false
		
		var hook_dir := get_global_mouse_position() - self.global_position
		hook_dir = hook_dir.normalized()
		
		var _hook := HOOK.instance()
		owner.add_child(_hook)
		_hook.shoot(self, hook_dir)
	
	if Input.is_action_just_released("ui_mouse_left"):
		can_grapple = true
		# need to find way to het reference to hook once it has been shot
	
	# Fire Bullet
	if Input.is_action_just_pressed("ui_mouse_right"):
		pass
	
	#velocity = move_and_slide(velocity, Vector2.UP)
