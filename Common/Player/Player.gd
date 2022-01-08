#--------------------------------------#
# Player Script                        #
#--------------------------------------#

extends KinematicBody2D

# Variables:
#---------------------------------------
const GRAVITY := 30
const TERMINAL_SPEED := 7500

const UP_DIR := Vector2.UP
const SNAP_DIR := Vector2.DOWN
const SNAP_VEC_LEN := 33
const MAX_SLIDES := 4
const MAX_SLOPE_ANGLE := deg2rad(46)

export var hook: PackedScene

var camera_zoom_base := 1.0
var camera_zoom_curent := 1.0
var camera_zoom_ease_base := 0.01
var camera_zoom_ease_current := 0.01

var is_boss_fight := false setget update_is_boss_fight

var gravity := GRAVITY
var jump_height := -700
var acceleration:= 33
var max_speed := 450
var limit_speed := max_speed

var do_stop_on_slope := true
var has_infinite_inertia := true
var snap_vector := SNAP_DIR * SNAP_VEC_LEN
var velocity := Vector2.ZERO
var input_dir := Vector2.ZERO

var can_shoot := true
var can_grapple := true
var is_flying := false

var hook_instance : KinematicBody2D


onready var anim_player = $AnimationPlayer
onready var camera = $PlayerCamera
onready var shotgun = $ShotGun



# Functions:
#---------------------------------------
func _ready() -> void:
	pass 


func _physics_process(delta) -> void:
	# apply gravity
	velocity.y += gravity
	
	if velocity.x > -limit_speed and velocity.x < limit_speed:
		velocity.x += input_dir.x * acceleration
	
	limit_speed = lerp(limit_speed, max_speed, 0.02)
	
	update_movement_inputs()
	apply_friction()
	clamp_speed()
	
	if is_on_wall(): 
		velocity = move_and_slide_with_snap(velocity, 
											snap_vector, 
											UP_DIR, 
											do_stop_on_slope, 
											MAX_SLIDES, 
											MAX_SLOPE_ANGLE, 
											has_infinite_inertia)
	else:
		velocity.y = move_and_slide_with_snap(velocity, 
											  snap_vector, 
											  UP_DIR, 
											  do_stop_on_slope, 
											  MAX_SLIDES, 
											  MAX_SLOPE_ANGLE, 
											  has_infinite_inertia).y
	
	update_sprite()
	update_camera()


func update_movement_inputs() -> void:
	# Input direction
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir = input_dir.normalized()
	
	# Jump
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			snap_vector = Vector2.ZERO
			velocity.y -= velocity.y # to fix 'super jump' bug when going up slopes
			velocity.y += jump_height
		
		else:
			snap_vector = SNAP_DIR * SNAP_VEC_LEN
		
		if is_flying:
			snap_vector = Vector2.ZERO
	
	# Shoot hook
	if Input.is_action_just_pressed("ui_mouse_left") and can_grapple:
		throw_grapple()
	
	if Input.is_action_just_released("ui_mouse_left"):
		release_grapple() 
	
	# Fire Shotgun
	if Input.is_action_just_pressed("ui_mouse_right") and can_shoot:
		is_flying = false
		snap_vector = Vector2.ZERO
		
		limit_speed = max_speed
		
		shotgun.shoot()


func throw_grapple() -> void:
	if !hook_instance:
		can_grapple = false
		can_shoot = false
		shotgun.visible = false
		
		var hook_dir := get_global_mouse_position() - self.global_position
		hook_dir = hook_dir.normalized()
		
		hook_instance = hook.instance()
		hook_instance.set_as_toplevel(true)
		add_child(hook_instance)
		hook_instance.shoot(self, hook_dir)


func release_grapple() -> void:
	if hook_instance:
		can_grapple = true
		can_shoot = true
		shotgun.visible = true
		
		hook_instance.release()
		hook_instance = null


func apply_friction() -> void:
	if is_on_floor():
		if can_grapple: # need a better way to do this - someone please implement a proper state machine or something for states (maybe)
			is_flying = false
		
		gravity = 0
		velocity.x = lerp(velocity.x, 0, 0.05)
		velocity.y = lerp(velocity.y, 0, 0.05)
		
	else:
		gravity = GRAVITY
		velocity.x = lerp(velocity.x, 0, 0.03)
		velocity.y = lerp(velocity.y, 0, 0.04)


func clamp_speed() -> void:
	velocity.x = clamp(velocity.x, -TERMINAL_SPEED, TERMINAL_SPEED)
	velocity.y = clamp(velocity.y, -TERMINAL_SPEED, TERMINAL_SPEED)


func update_sprite() -> void:
	if input_dir.x > 0:
		$Sprite.scale.x = 1
		
	elif input_dir.x < 0:
		$Sprite.scale.x = -1


func update_camera() -> void:
	camera_zoom_curent = camera_zoom_base
	camera_zoom_ease_current = 0.01
	
	if velocity.length() > max_speed:
		camera_zoom_curent = velocity.length() / (max_speed * 0.8) # change to variable later
		camera_zoom_curent = clamp(camera_zoom_curent, 1, 2)
		camera_zoom_ease_current = camera_zoom_ease_base
	
	else:
		camera_zoom_curent = camera_zoom_base
		camera_zoom_ease_current = 0.08
	
	camera.zoom = lerp(camera.zoom, Vector2(1, 1) * camera_zoom_curent, camera_zoom_ease_current)


func update_is_boss_fight(value : bool) -> void:
	is_boss_fight = value
	
	if is_boss_fight:
		camera_zoom_base = 1.6
	
	else:
		camera_zoom_base = 1.0


# damaged
func _on_HurtBox_area_entered(area: Area2D) -> void:
	anim_player.play("damaged")
	
	release_grapple() 
	PlayerStats.current_health -= area.damage
	print("Damage amount: ", area.damage)
	
	if area.knock_back_force > 0:
		var dir_knockback = (self.get_global_position() - area.get_global_position()).normalized()
		velocity = dir_knockback * area.knock_back_force 

