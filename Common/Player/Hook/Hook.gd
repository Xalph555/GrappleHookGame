#--------------------------------------#
# Grapple Hook Script                  #
#--------------------------------------#
extends KinematicBody2D

class_name GrappleHook


# Variables
#---------------------------------------
export var chain: PackedScene

var _pull_x := 30
var _pull_y := 90
var _hook_pull := Vector2(_pull_x, _pull_y)

var _move_dir := Vector2.ZERO
var _hook_dir := Vector2.ZERO
var _velocity := Vector2.ZERO

var _distance_to_parent := 0.0

var _is_hooked := false

var _hooked_obj : KinematicBody2D
var _hooked_local_pos := Vector2.ZERO
var _hooked_obj_rot_offset := 0.0

#var _hooked_obj_dist := 0.0
#var _hooked_obj_dir := Vector2.ZERO

var _player: KinematicBody2D
var _current_speed := 0
var _min_speed := 3000
var _max_speed := 3000;

var chains := []
var hook_path := []


# Functions:
#---------------------------------------
func _physics_process(delta: float) -> void:
	_distance_to_parent = self.global_position.distance_to(_player.global_position)
	_hook_dir = (self.global_position - _player.global_position).normalized()
	
	display_chain()
	
	if _is_hooked:
		apply_tension()
		update_hook_position() 
	
	else:
		fly_hook(delta)


func display_chain():
	for x in $Chains.get_children():
		x.call_deferred("queue_free")

	if hook_path.empty():
		var new_chain = chain.instance()
		new_chain.set_as_toplevel(true)
		$Chains.add_child(new_chain)
		new_chain.draw_between(_player.global_position, self.global_position)
		return
		
	# chain graphics
	# display from the person to the first portal
	var new_chain = chain.instance()
	new_chain.set_as_toplevel(true)
	$Chains.add_child(new_chain)
	new_chain.draw_between(_player.global_position, hook_path[0].global_position)
	
	# display between each portal
	for i in range(2, len(hook_path), 2):
		new_chain = chain.instance()
		new_chain.set_as_toplevel(true)
		$Chains.add_child(new_chain)
		new_chain.draw_between(hook_path[i-1].global_position, hook_path[i].global_position)
	
	# display from the last portal to the hook position
	new_chain = chain.instance()
	new_chain.set_as_toplevel(true)
	$Chains.add_child(new_chain)
	new_chain.draw_between(hook_path[len(hook_path)-1].global_position, self.global_position)


func fly_hook(delta: float):
	_velocity = _move_dir * _min_speed * delta
	
	var collided = move_and_collide(_velocity)
	
	if collided:
		self.rotation = collided.normal.angle() + deg2rad(180)
		display_chain()
		
		_hooked_obj = instance_from_id(collided.collider_id) as KinematicBody2D
		
		if _hooked_obj:
			_hooked_local_pos = _hooked_obj.to_local(self.global_position)
			
			var angle_to_hooked := self.global_position.direction_to(_hooked_obj.global_position).angle()
			_hooked_obj_rot_offset = self.rotation - angle_to_hooked
		
		_is_hooked = true
		_move_dir = Vector2.ZERO


func apply_tension():
	_player.is_flying = true
	
	# if a portal is entered then apply tension towards the nearest portal
	var dir: = Vector2()
	if !hook_path.empty():
		dir = (hook_path[0].global_position - _player.global_position).normalized()
	
	else:
		dir = _hook_dir
	
	_hook_pull.x = sign(dir.x) * abs(_hook_pull.x)
	_hook_pull.y = sign(dir.y) * abs(_hook_pull.y)
	
	var tension_vec := dir * dir.dot(_hook_pull)
	
	# dead space
	var dead_space := 30.00
	if _distance_to_parent < dead_space:
		_player.global_position = (-_hook_dir * dead_space) + self.global_position
		tension_vec = Vector2.ZERO
	
	_player.limit_speed = _player.max_speed * 1.6
	_player.velocity += tension_vec 


func update_hook_position() -> void:
	if _hooked_obj:
		self.global_position = _hooked_obj.to_global(_hooked_local_pos)
		
		var angle_to_hooked := self.global_position.direction_to(_hooked_obj.global_position).angle()
		self.rotation = angle_to_hooked + _hooked_obj_rot_offset



func shoot(shooter: KinematicBody2D, dir: Vector2) -> void:
	_player = shooter
	position = _player.global_position
	hook_path = []
	
	_current_speed = _max_speed
	_move_dir = dir
	rotation = dir.angle()
	
	_is_hooked = false


func handle_teleporter(start_portal) -> void:
	if start_portal._portal_connections.empty():
		return
		
	var exit_portal = start_portal._portal_connections[0]
	
	hook_path.append(start_portal)
	hook_path.append(exit_portal)
	
	var enter_dir = self._velocity.normalized()
	var exit_angle = enter_dir.angle_to(exit_portal.exit_dir)
	
	self.global_position = exit_portal.global_position
	self._move_dir = self._move_dir.rotated(exit_angle)


func release() -> void:
	call_deferred("free")
