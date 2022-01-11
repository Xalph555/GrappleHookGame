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

var is_boss_fight := false setget updateis_boss_fight

var gravity := _GRAVITY
var jump_height := -700
var acceleration:= 33
var max_speed := 450
var limit_speed := max_speed

var _do_stop_on_slope := true
var _has_infinite_inertia := true
var _snap_vector := _SNAP_DIR * _SNAP_VEC_LEN
var velocity := Vector2.ZERO
var _input_dir := Vector2.ZERO

var _can_shoot := true
var _can_grapple := true
var is_flying := false

var _hook_instance : GrappleHook

onready var _anim_player = $AnimationPlayer
onready var _camera = $PlayerCamera
onready var _shotgun = $ShotGun as Shotgun


# Functions:
#---------------------------------------
func _physics_process(delta) -> void:
	# apply gravity
	velocity.y += gravity
	
	if velocity.x > -limit_speed and velocity.x < limit_speed:
		velocity.x += _input_dir.x * acceleration
	
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
	
	update_sprite()
	update_camera()


func update_movement_inputs() -> void:
	# Input direction
	_input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	_input_dir = _input_dir.normalized()
	
	# Jump
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			_snap_vector = Vector2.ZERO
			velocity.y -= velocity.y # to fix 'super jump' bug when going up slopes
			velocity.y += jump_height
		
		else:
			_snap_vector = _SNAP_DIR * _SNAP_VEC_LEN
		
		if is_flying:
			_snap_vector = Vector2.ZERO
	
	# Shoot hook
	if Input.is_action_just_pressed("ui_mouse_left") and _can_grapple:
		throw_grapple()
	
	if Input.is_action_just_released("ui_mouse_left"):
		release_grapple() 
	
	# Fire Shotgun
	if Input.is_action_just_pressed("ui_mouse_right") and _can_shoot:
		is_flying = false
		_snap_vector = Vector2.ZERO
		
		limit_speed = max_speed
		
		_shotgun.shoot()


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


func apply_friction() -> void:
	if is_on_floor():
		if _can_grapple: # need a better way to do this - someone please implement a proper state machine or something for states (maybe)
			is_flying = false
		
		gravity = 0
		velocity.x = lerp(velocity.x, 0, 0.05)
		velocity.y = lerp(velocity.y, 0, 0.05)
		
	else:
		gravity = _GRAVITY
		velocity.x = lerp(velocity.x, 0, 0.03)
		velocity.y = lerp(velocity.y, 0, 0.04)


func clamp_speed() -> void:
	velocity.x = clamp(velocity.x, -_TERMINAL_SPEED, _TERMINAL_SPEED)
	velocity.y = clamp(velocity.y, -_TERMINAL_SPEED, _TERMINAL_SPEED)


func update_sprite() -> void:
	if _input_dir.x > 0:
		$Sprite.scale.x = 1
		
	elif _input_dir.x < 0:
		$Sprite.scale.x = -1


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


func updateis_boss_fight(value : bool) -> void:
	is_boss_fight = value
	
	if is_boss_fight:
		_camera_zoom_base = 1.6
	
	else:
		_camera_zoom_base = 1.0


# damaged
func _on_HurtBox_area_entered(area: Area2D) -> void:
	_anim_player.play("damaged")
	
	release_grapple() 
	PlayerStats.current_health -= area.damage
	print("Damage amount: ", area.damage)
	
	if area.knock_back_force > 0:
		var dir_knockback = (self.get_global_position() - area.get_global_position()).normalized()
		velocity = dir_knockback * area.knock_back_force 
