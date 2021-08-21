extends KinematicBody2D

const HOOK := preload("res://Player/Hook/Hook.tscn")

var weight := 40
var jump_height := -1500
var move_speed := 550

var input_dir := Vector2.ZERO
var velocity := Vector2.ZERO

var can_grapple := true



func _ready() -> void:
	pass 


func _physics_process(delta) -> void:
	velocity.y += WorldGlobals.apply_gravity(weight)
	
	# Run
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir = input_dir.normalized()
	
	# Jump
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y += jump_height
	
	# Shoot hook
	if Input.is_action_just_pressed("ui_mouse_left") && can_grapple:
		#can_grapple = false
		
		var hook_dir := get_global_mouse_position() - self.global_position
		hook_dir = hook_dir.normalized()
		
		var _hook := HOOK.instance()
		owner.add_child(_hook)
		_hook.shoot(self, hook_dir)
	
	# Fire Bullet
	if Input.is_action_just_pressed("ui_mouse_right"):
		pass
	
	velocity.x = move_speed * input_dir.x
	velocity = move_and_slide(velocity, Vector2.UP)
