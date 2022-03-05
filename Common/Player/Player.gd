#--------------------------------------#
# Player Script                        #
#--------------------------------------#
extends KinematicBody2D

class_name Player


# Variables:
#---------------------------------------
const _GRAVITY := 30
const _TERMINAL_SPEED := 7500

const _UP_DIR := Vector2.UP
const _SNAP_DIR := Vector2.DOWN
const _SNAP_VEC_LEN := 33
const _MAX_SLIDES := 4
const _MAX_SLOPE_ANGLE := deg2rad(46)

export var hook: PackedScene

var _camera_zoom_base := 1.0
var _camera_zoom_curent := 1.0
var _camera_zoom_ease_base := 0.01
var _camera_zoom_ease_current := 0.01

var is_boss_fight := false setget update_is_boss_fight

var gravity := _GRAVITY
var jump_height := -700
var acceleration:= 35
var max_speed := 480
var limit_speed := max_speed

var _do_stop_on_slope := true
var _has_infinite_inertia := true
var _snap_vector := _SNAP_DIR * _SNAP_VEC_LEN
var velocity := Vector2.ZERO
var _input_dir := Vector2.ZERO

var _can_jump := true
var _jump_was_pressed := false

var _can_shoot := true
var _can_grapple := true
var is_flying := false

var _hook_instance : GrappleHook

var _dash_factor := 1.8
var _dash_duration := 0.2

onready var _anim_tree_main := $AnimationTreeMain
onready var _anim_tree_main_state = _anim_tree_main.get("parameters/playback")
onready var _anim_player_main := $AnimationPlayerMain
onready var _anim_player_sec := $AnimationPlayerSec
onready var _camera := $PlayerCamera

onready var _shotgun := $ShotGun as Shotgun
onready var _mouse_pointer := $MousePointer
onready var _dash_hitbox := $DashHitBox
onready var _dash_particles := $DashHitBox/CollisionShape2D/DashParticles


# Functions:
#---------------------------------------
func _ready() -> void:
	PlayerStats.save_stats()
	_dash_hitbox.disable_hit_box()


func _physics_process(delta) -> void:
	# apply gravity
	velocity.y += gravity
	
	velocity.x = clamp(velocity.x + (_input_dir.x * acceleration), -limit_speed, limit_speed)
	
	limit_speed = lerp(limit_speed, max_speed, 0.02)
	
	update_movement_inputs()
	apply_friction()
	clamp_speed()
	

	if is_on_wall(): 
		velocity = move_and_slide_with_snap(velocity, 
											_snap_vector, 
											_UP_DIR, 
											_do_stop_on_slope, 
											_MAX_SLIDES, 
											_MAX_SLOPE_ANGLE, 
											_has_infinite_inertia)
	else:
		velocity.y = move_and_slide_with_snap(velocity, 
											  _snap_vector, 
											  _UP_DIR, 
											  _do_stop_on_slope, 
											  _MAX_SLIDES, 
											  _MAX_SLOPE_ANGLE, 
											  _has_infinite_inertia).y
	
	# slight issue found (25/01/2022) - player moves faster up slopes than down
	# 								  - could be because of move_and_slide_with_snap?
	
	update_sprite()
	update_camera()


func update_movement_inputs() -> void:
	# Input direction
	_input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	_input_dir = _input_dir.normalized()
	
	# Jump
	if is_on_floor():
		if _can_grapple: 
			is_flying = false
			
		_can_jump = true
		
		if _jump_was_pressed:
			jump()
			
	else:
		coyote_time()
	
	if Input.is_action_just_pressed("jump"):
		_jump_was_pressed = true
		remember_jump_time()
		
		if _can_jump:
			jump()
		
	else:
		if is_flying:
			_snap_vector = Vector2.ZERO
			
		else:
			_snap_vector = _SNAP_DIR * _SNAP_VEC_LEN
	
	# Shoot hook
	if Input.is_action_just_pressed("grapple") and _can_grapple:
		_mouse_pointer.visible = false
		throw_grapple()
	
	if Input.is_action_just_released("grapple"):
		_mouse_pointer.visible = true
		release_grapple() 
	
	# Fire Shotgun
	if Input.is_action_just_pressed("shoot") and _can_shoot:
		is_flying = false
		_snap_vector = Vector2.ZERO
		
		limit_speed = max_speed
		
		_shotgun.shoot()
	
	# Dash
	if Input.is_action_just_released("dash") and is_flying and _can_grapple:
		dash()


func jump() -> void:
	_snap_vector = Vector2.ZERO
	velocity.y -= velocity.y # to fix 'super jump' bug when going up slopes
	velocity.y += jump_height


func remember_jump_time() -> void:
	yield(get_tree().create_timer(0.1), "timeout")
	_jump_was_pressed = false


func coyote_time() -> void:
	yield(get_tree().create_timer(0.1), "timeout")
	_can_jump = false


func throw_grapple() -> void:
	if !_hook_instance:
		_can_grapple = false
		_can_shoot = false
		_shotgun.visible = false
		
		var hook_dir := get_global_mouse_position() - self.global_position
		hook_dir = hook_dir.normalized()
		
		_hook_instance = hook.instance()
		_hook_instance.set_as_toplevel(true)
		add_child(_hook_instance)
		_hook_instance.shoot(self, hook_dir)


func release_grapple() -> void:
	if _hook_instance:
		_can_grapple = true
		_can_shoot = true
		_shotgun.visible = true
		
		_hook_instance.release()
		_hook_instance = null


func dash() -> void:
	is_flying = false
	_can_grapple = false
	
	_mouse_pointer.visible = false
	
	var mouse_dir := (get_global_mouse_position() - self.global_position).normalized()
	_dash_hitbox.rotation = mouse_dir.angle()
	_dash_hitbox.enable_hit_box()
	_dash_particles.emitting = true
	
	var dash_force := velocity.length() * _dash_factor
	var dash_vector := Vector2(dash_force, dash_force) * mouse_dir
	
	# Set dash damage scaling with current speed
	_dash_hitbox.damage = velocity.length() * 0.2
	print(_dash_hitbox.damage)

	limit_speed = dash_force
	velocity = dash_vector

	# lock controls - no shooting/ grapple
	yield(get_tree().create_timer(_dash_duration), "timeout")
	
	_dash_hitbox.disable_hit_box()
	_can_grapple = true
	_mouse_pointer.visible = true


func apply_friction() -> void:
	if is_on_floor():
		gravity = 0
		velocity.x = lerp(velocity.x, 0, 0.05)
		velocity.y = lerp(velocity.y, 0, 0.05)
		
	else:
		gravity = _GRAVITY
		velocity.x = lerp(velocity.x, 0, 0.03)
		velocity.y = lerp(velocity.y, 0, 0.03)


func clamp_speed() -> void:
	velocity.x = clamp(velocity.x, -_TERMINAL_SPEED, _TERMINAL_SPEED)
	velocity.y = clamp(velocity.y, -_TERMINAL_SPEED, _TERMINAL_SPEED)


func update_sprite() -> void:
	# sprite flipping
	if _input_dir.x > 0:
		$Sprite.scale.x = 1
		
	elif _input_dir.x < 0:
		$Sprite.scale.x = -1
	
	var _can_slide : bool =  is_on_floor() and \
							 velocity.y >= 0 and \
							 velocity.length() > max_speed
	
	if _can_slide:
		_anim_tree_main_state.travel("Slide")
		
	else:
		_anim_tree_main_state.travel("Idle")
		
	# update mouse pointer
	if is_flying:
		_mouse_pointer.set_dash_pointer()
	
	else:
		_mouse_pointer.set_normal_pointer()


func update_camera() -> void:
	_camera_zoom_curent = _camera_zoom_base
	_camera_zoom_ease_current = 0.01
	
	if velocity.length() > max_speed:
		_camera_zoom_curent = velocity.length() / (max_speed * 0.8) # change to variable later
		_camera_zoom_curent = clamp(_camera_zoom_curent, 1, 2)
		_camera_zoom_ease_current = _camera_zoom_ease_base
	
	else:
		_camera_zoom_curent = _camera_zoom_base
		_camera_zoom_ease_current = 0.08
	
	_camera.zoom = lerp(_camera.zoom, Vector2(1, 1) * _camera_zoom_curent, _camera_zoom_ease_current)


func update_is_boss_fight(value : bool) -> void:
	is_boss_fight = value
	
	if is_boss_fight:
		_camera_zoom_base = 1.6
	
	else:
		_camera_zoom_base = 1.0


# damaged
func _on_HurtBox_area_entered(area: Area2D) -> void:
	var hitbox = area as Hitbox
	
	if hitbox:
		_anim_player_sec.play("damaged")
		
		release_grapple() 
		PlayerStats.current_health -= hitbox.damage
		
		print("Damage amount: ", hitbox.damage)
		
		if hitbox.knock_back_force > 0:
			var dir_knockback = (self.get_global_position() - hitbox.get_global_position()).normalized()
			velocity = dir_knockback * hitbox.knock_back_force 
			
			_anim_tree_main_state.travel("Idle")
	
	else:
		print("Hurt by something that does not have a Hitbox")

