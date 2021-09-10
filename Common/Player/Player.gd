extends KinematicBody2D

const HOOK := preload("res://Common/Player/Hook/Hook.tscn")

var input_dir := Vector2.ZERO

var weight := 40
var jump_height := -2500
var acceleration:= 65
var max_speed_x := 1000
var max_speed_y := 3000

var velocity := Vector2.ZERO

var can_grapple := true
var is_flying := false

var hook_instance : KinematicBody2D


func _ready() -> void:
	pass 


func _physics_process(delta) -> void:
	#Gravity
	velocity.y += WorldGlobals.apply_gravity(weight)
	
	# Run
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir = input_dir.normalized()

	velocity.x += input_dir.x * acceleration
	
	if is_on_floor():
		if is_flying:
			is_flying = false
		
		# Jump
		if Input.is_action_pressed("ui_up"):
			velocity.y += jump_height
			
		velocity.x = lerp(velocity.x, 0, 0.04)
			
	else:
		velocity.x = lerp(velocity.x, 0, 0.03)
		velocity.y = lerp(velocity.y, 0, 0.05)
	
	if is_flying:
		velocity.x = clamp(velocity.x, -max_speed_x*3, max_speed_x*3)
		velocity.y = clamp(velocity.y, -max_speed_y*1.1, max_speed_y*1.1)
		
	else:
		velocity.x = clamp(velocity.x, -max_speed_x, max_speed_x)
		velocity.y = clamp(velocity.y, -max_speed_y, max_speed_y)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	
	# Shoot hook
	if Input.is_action_just_pressed("ui_mouse_left") and can_grapple:
		can_grapple = false
		
		var hook_dir := get_global_mouse_position() - self.global_position
		hook_dir = hook_dir.normalized()
		
		hook_instance = HOOK.instance()
		owner.add_child(hook_instance)
		hook_instance.shoot(self, hook_dir)
	
	if Input.is_action_just_released("ui_mouse_left"):
		can_grapple = true
		
		hook_instance.release()
	
	# Fire Bullet
	if Input.is_action_just_pressed("ui_mouse_right"):
		pass
