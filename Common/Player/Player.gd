#--------------------------------------#
# Player Script                        #
#--------------------------------------#

extends KinematicBody2D

# Variables:
#---------------------------------------
export var hook: PackedScene

var weight := 40
var jump_height := -2500
var acceleration:= 65
var max_speed_x := 1000
var max_speed_y := 3000

var velocity := Vector2.ZERO
var input_dir := Vector2.ZERO

var can_shoot := true
var can_grapple := true
var is_flying := false

var hook_instance : KinematicBody2D

onready var shotgun = $ShotGun



# Functions:
#---------------------------------------
func _ready() -> void:
	pass 


func _unhandled_input(event: InputEvent) -> void:
	# Input direction
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir = input_dir.normalized()
	
	# Jump
	if is_on_floor():
		if event.is_action_pressed("ui_up"):
			velocity.y += jump_height
	
	# Shoot hook
	if event.is_action_pressed("ui_mouse_left") and can_grapple:
		can_grapple = false
		can_shoot = false
		shotgun.visible = false
		
		var hook_dir := get_global_mouse_position() - self.global_position
		hook_dir = hook_dir.normalized()
		
		hook_instance = hook.instance()
		owner.add_child(hook_instance)
		hook_instance.shoot(self, hook_dir)
	
	if event.is_action_released("ui_mouse_left"):
		can_grapple = true
		can_shoot = true
		shotgun.visible = true
		
		hook_instance.release()
	
	# Fire Shotgun
	if event.is_action_pressed("ui_mouse_right") and can_shoot:
		is_flying = false
		shotgun.shoot()


func _physics_process(delta) -> void:
	velocity.y += WorldGlobals.apply_gravity(weight)

	velocity.x += input_dir.x * acceleration
	
	apply_friction()
	limit_speed()
	
	velocity = move_and_slide(velocity, Vector2.UP)


func apply_friction():
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0, 0.04)
	
	else:
		velocity.x = lerp(velocity.x, 0, 0.03)
		velocity.y = lerp(velocity.y, 0, 0.05)


func limit_speed():
	if is_on_floor() and sign(input_dir.x) != 0:
		is_flying = false
		#print("is not flying anymore")
		
	if is_flying:
		#print("is flying ")
		velocity.x = clamp(velocity.x, -max_speed_x * 3.5, max_speed_x * 3.5)
		velocity.y = clamp(velocity.y, -max_speed_y * 1.5, max_speed_y * 1.5)
		
	else:
		velocity.x = clamp(velocity.x, -max_speed_x, max_speed_x)
		velocity.y = clamp(velocity.y, -max_speed_y, max_speed_y)
