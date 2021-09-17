extends KinematicBody2D

const HOOK := preload("res://common/Player/Hook/Hook.tscn")
const BULLET := preload("res://common/Bullet/Bullet.tscn")

onready var shotgun = $Shotgun
var input_dir := Vector2.ZERO

var weight := 40
var jump_vel := -2500
var acceleration:= 65
var max_speed_x := 1000
var max_speed_y := 3000

var velocity := Vector2.ZERO

var can_grapple := true

var hook_instance : KinematicBody2D
var bullet : KinematicBody2D

func _ready() -> void:
	pass 


func handle_user_input_movement():
	# Run
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir = input_dir.normalized()

	velocity.x += input_dir.x * acceleration
	
	if is_on_floor():
		if Input.is_action_pressed("ui_up"):
			velocity.y += jump_vel


func apply_friction():
	# floor friction
	if is_on_floor():
		velocity *= 0.96
		
	# air friction
	velocity *= 0.97
	

func fire_hook():
	var hook_dir := get_global_mouse_position() - self.global_position
	hook_dir = hook_dir.normalized()
	
	hook_instance = HOOK.instance()
	hook_instance.init(self, hook_dir)
	owner.add_child(hook_instance)
	
	
func _physics_process(delta) -> void:
	#Gravity
	velocity.y += WorldGlobals.apply_gravity(weight)
	handle_user_input_movement()
	
	# Shoot hook
	if Input.is_action_just_pressed("ui_mouse_left"):
		fire_hook()
		
	if Input.is_action_just_released("ui_mouse_left"):
		hook_instance.release()
	
	# Fire Bullet
	if Input.is_action_just_pressed("ui_mouse_right"):
		owner.add_child(BULLET.instance().init(self, Vector2(0,1), 100))
#		shotgun.fire_shotgun()
	
	apply_friction()
	velocity = move_and_slide(velocity, Vector2.UP)
