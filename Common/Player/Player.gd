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

# camera
var _camera_zoom_base := 1.0
var _camera_zoom_curent := 1.0
var _camera_zoom_ease_base := 0.01
var _camera_zoom_ease_current := 0.01

# boss fight
var is_boss_fight := false setget update_is_boss_fight

# movement
var gravity := _GRAVITY
var jump_height := -700
var acceleration:= 35
var max_speed := 480
onready var limit_speed := max_speed

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

# pickups
var selected_pickup : GunUpgradePickup
var _choosing_upgrade := false

onready var _anim_tree_main := $AnimationTreeMain
onready var _anim_tree_main_state = _anim_tree_main.get("parameters/playback")
onready var _anim_player_main := $AnimationPlayerMain
onready var _anim_player_sec := $AnimationPlayerSec
onready var _camera := $PlayerCamera

#onready var _shotgun := $ShotGun as Shotgun
onready var _gun_extension := $ProtoGunExtension
onready var _upgrade_menu := $GunUpgradeSelection

onready var _mouse_pointer := $MousePointer

onready var _dash_hitbox := $DashHitBox
onready var _dash_particles := $DashHitBox/CollisionShape2D/DashParticles


# Functions:
#---------------------------------------
func _ready() -> void:
	PlayerStats.save_stats()
	_dash_hitbox.disable_hit_box()

	yield(get_tree(), "idle_frame")
	_gun_extension.set_up(self)

	set_choosing_upgrade(false)


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
		
		#_shotgun.shoot()
		_gun_extension.shoot()
	
	# Dash
	if Input.is_action_just_released("dash") and is_flying and _can_grapple:
		dash()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		if selected_pickup:
			pickup_item()
	
	if _choosing_upgrade:
		if event.is_action_pressed("ui_cancel"):
			set_choosing_upgrade(false)
		
		# attach upgrade to selected slot
		if event.is_action_pressed("Selection1"):
			set_choosing_upgrade(false)
			_gun_extension.attach_upgrade(1, selected_pickup.upgrade)
			remove_selected_pickup() 
		
		if event.is_action_pressed("Selection2"):
			set_choosing_upgrade(false)
			_gun_extension.attach_upgrade(2, selected_pickup.upgrade)
			remove_selected_pickup() 
		
		if event.is_action_pressed("Selection3"):
			set_choosing_upgrade(false)
			_gun_extension.attach_upgrade(3, selected_pickup.upgrade)
			remove_selected_pickup() 


func pickup_item() -> void:
	if selected_pickup.get_class() == "GunUpgradePickup":
		# ---- get and check incompatability (to be impemented)

		var gun_upgrade_type = selected_pickup.upgrade.gun_upgrade_type
		# print(gun_upgrade_type)

		if gun_upgrade_type == GunUpgradeResource.GUN_UPGRADE_TYPES.ATTRIBUTE_UPGRADE:
			var free_slot = _gun_extension.get_free_upgrade_slot()

			if free_slot != -1:
				_gun_extension.attach_upgrade(free_slot, selected_pickup.upgrade)

				remove_selected_pickup() 
			
			else:
				set_choosing_upgrade(true)

				print("No free gun upgrade slot")
			
		elif gun_upgrade_type == GunUpgradeResource.GUN_UPGRADE_TYPES.BARREL_UPGRADE:
			_gun_extension.attach_barrel(selected_pickup.upgrade)

			remove_selected_pickup() 
		
		else:
			print("no pickup")
		
	else:
		print("no pickup")


func remove_selected_pickup() -> void:
	selected_pickup.call_deferred("free")
	selected_pickup = null


# gun pickups
func set_choosing_upgrade(can_choose : bool) -> void:
	_choosing_upgrade = can_choose

	if can_choose:
		_upgrade_menu.display_attached_upgrades(selected_pickup.upgrade.display_name, _gun_extension.get_all_attachments())
	
	else:
		_upgrade_menu.hide_attached_upgrades()


# movement functions
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


# grapple hook functions
func throw_grapple() -> void:
	if !_hook_instance:
		_can_grapple = false
		_can_shoot = false
		#_shotgun.visible = false
		_gun_extension.visible = false
		
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
		#_shotgun.visible = true
		_gun_extension.visible = true
		
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
	var dash_vector := mouse_dir * dash_force
	
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


func handle_teleporter(portal):
	var enter_dir = self.velocity.normalized()
	var exit_angle = enter_dir.angle_to(portal._portal_connections[0].exit_dir)
	var exit_impulse = portal._portal_connections[0].exit_dir * portal._portal_connections[0].exit_force
	
	self.global_position = portal._portal_connections[0].global_position
	self.velocity = self.velocity.rotated(exit_angle) + exit_impulse
	
	if _hook_instance != null:
		if _hook_instance.hook_path.empty() or _hook_instance.hook_path[0] != portal:
			_hook_instance.hook_path.insert(0, portal)
			_hook_instance.hook_path.insert(0, portal._portal_connections[0])
		else:
			_hook_instance.hook_path.pop_front()
			_hook_instance.hook_path.pop_front()


# other
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
	
	if area.knock_back_force > 0:
		var dir_knockback = (self.get_global_position() - area.get_global_position()).normalized()
		velocity = dir_knockback * area.knock_back_force 

	else:
		print("Hurt by something that does not have a Hitbox")

func _on_HurtBox_body_entered(body:Node) -> void:
	pass # Replace with function body.


# handling pickups
func _on_PickupRange_body_entered(body:Node) -> void:
	if selected_pickup and body == selected_pickup:
		return
	
	if selected_pickup:
		selected_pickup.highlight_pickup(false)

	selected_pickup = body
	selected_pickup.highlight_pickup(true)

func _on_PickupRange_body_exited(body:Node) -> void:
	if selected_pickup and body == selected_pickup:
		set_choosing_upgrade(false)

		selected_pickup.highlight_pickup(false)
		selected_pickup = null
	
