extends KinematicBody2D


export(PackedScene) var projectile = projectile as Projectile

const _UP_DIR := Vector2.UP
const _SNAP_DIR := Vector2.DOWN
const _SNAP_VEC_LEN := 33
const _MAX_SLIDES := 4
const _MAX_SLOPE_ANGLE := deg2rad(46)

var _target : KinematicBody2D
var _vector_to_target : Vector2
var _dir_to_target : Vector2
var _dist_to_target : float

var _move_away_dist := 200

var _do_stop_on_slope := true
var _has_infinite_inertia := true
var _snap_vector := _SNAP_DIR * _SNAP_VEC_LEN
var _gravity := 30
var _move_speed := 150
var _move_dir : Vector2
var _velocity : Vector2

var _can_see_target := false
var _was_out_of_sight := true

onready var _throw_delay := $ThrowDelay
onready var _target_tracker := $TargetTracker


func _physics_process(delta: float) -> void:
	_velocity.y += _gravity
	
	if _target:
		# target orientation data
		_vector_to_target = _target.global_position - self.global_position
		_dir_to_target = _vector_to_target.normalized()
		_dist_to_target = self.global_position.distance_to(_target.global_position)
		
		_target_tracker.rotation = _vector_to_target.angle()
		
		# target is visable to lobber
		_can_see_target = _target_tracker.is_colliding() && _target_tracker.get_collider() == _target
		
		if _can_see_target:
			if _was_out_of_sight:
				_was_out_of_sight = false
				$AnimationPlayer.play("Jump")
			
			update_sprite()
			
			check_movement()
			update_movement()
			
		else:
			_was_out_of_sight = true


func check_movement() -> void:
	var can_move : bool = _dist_to_target <= _move_away_dist and \
						  (!is_on_floor() or $Sprite/GroundRay.is_colliding())
	
	if can_move:
		_move_dir = -_dir_to_target
	
	else:
		_move_dir = Vector2.ZERO


func update_movement() -> void:
	_velocity.x = _move_dir.x * _move_speed
	
	if is_on_wall(): 
		_velocity = move_and_slide_with_snap(_velocity, 
											_snap_vector, 
											_UP_DIR, 
											_do_stop_on_slope, 
											_MAX_SLIDES, 
											_MAX_SLOPE_ANGLE, 
											_has_infinite_inertia)
	else:
		_velocity.y = move_and_slide_with_snap(_velocity, 
											  _snap_vector, 
											  _UP_DIR, 
											  _do_stop_on_slope, 
											  _MAX_SLIDES, 
											  _MAX_SLOPE_ANGLE, 
											  _has_infinite_inertia).y


func update_sprite() -> void:
	if _dir_to_target.x < 0:
		$Sprite.scale.x = 1
		
	elif _dir_to_target.x > 0:
		$Sprite.scale.x = -1


func calculate_throw_velocity(point_a: Vector2, point_b: Vector2, arc_height: float, \
							  up_gravity: float, down_gravity = null) -> Vector2:
	# source (Game Endeavor): https://www.youtube.com/watch?v=_kA1fbBH4ug

	# Note to self (30 Nov 21): Learn how equations of motions work
	
	if down_gravity == null:
		down_gravity = up_gravity
	
	var throw_velocity := Vector2()
	
	var displacement := point_b - point_a
	
	if displacement.y > arc_height:
		var time_up := sqrt(-2 * arc_height / float(up_gravity))
		var time_down := sqrt(2 * (displacement.y - arc_height) / float(down_gravity))
		
		throw_velocity.y = -sqrt(-2 * up_gravity * arc_height)
		throw_velocity.x = displacement.x / float(time_up + time_down)
	
	return throw_velocity


func _on_ThrowDelay_timeout() -> void:
	# if can see 
	if _can_see_target:
		var _projectile := projectile.instance() as Projectile
		#get_viewport().add_child(_projectile) # not sure if spawning on viewport is good idea
		_projectile.set_as_toplevel(true)
		add_child(_projectile)
		
		var arc_height = _target.global_position.y - self.global_position.y - 32
		arc_height = min(arc_height, -32)
		
		_projectile.global_position = self.global_position
		_projectile.linear_velocity = calculate_throw_velocity(self.global_position, \
											_target.global_position, arc_height, _projectile.gravity)
	
	_throw_delay.start()


func _on_AttackRange_body_entered(body: Node) -> void:
	_target = body as KinematicBody2D
	
	if _target:
		_throw_delay.start()


func _on_AttackRange_body_exited(body: Node) -> void:
	if body is KinematicBody2D:
		_target = null
		_throw_delay.stop()


# damaged
func _on_HurtBox_area_entered(area: Area2D) -> void:
	queue_free()
