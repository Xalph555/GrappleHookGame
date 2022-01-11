#--------------------------------------#
# BlitzOrb Script                      #
#--------------------------------------#
extends KinematicBody2D

class_name BlitzOrb


# Variables:
#---------------------------------------
var _hover_dist := 180
var _target : Node = null

var _move_speed := 1010
var _move_dir := Vector2.ZERO
var _velocity := Vector2.ZERO

var _max_dashes := 5
var _current_dashes := _max_dashes
var _is_attacking := false

var _rng := RandomNumberGenerator.new()


# Functions:
#---------------------------------------
func _ready() -> void:
	_rng.randomize()
	var _dash_offset = _rng.randf_range(0, 1)
	$DashCoolDown.wait_time += _dash_offset


func _physics_process(delta: float) -> void:
	if _target != null and _current_dashes > 0:
		if !_is_attacking:
			follow_target()
		
		_velocity = _move_speed * _move_dir
		_velocity = move_and_slide(_velocity)
	
	else:
		$DashCoolDown.stop()


func follow_target() -> void:
	var _dir_to_target: Vector2 = (_target.global_position - self.global_position).normalized()
	var _hover_point: Vector2 = _target.global_position - (_dir_to_target * _hover_dist)
	
	global_position = lerp(global_position, _hover_point, 0.1)


# this needs to be cleaned up
func dash_attack() -> void:
	$AnimationPlayer.play("flash")
	yield($AnimationPlayer, "animation_finished")
	set_attack(true)
	
	var _vector_to_target : Vector2 = _target.global_position - self.global_position 
	_move_dir = _vector_to_target.normalized()
	_move_speed *= 1.8
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	_move_dir = Vector2.ZERO
	_move_speed /= 1.8
	
	yield(get_tree().create_timer(0.1), "timeout")
	set_attack(false)
	$DashCoolDown.start()
	_current_dashes -= 1


func set_attack(attacking: bool) -> void:
	_is_attacking = attacking
	$Trail.visible = attacking
	$CollisionShape2D.disabled = attacking


func _on_DashCoolDown_timeout() -> void:
	dash_attack()


func _on_AttackRange_body_entered(body: Node) -> void:
	_target = body
	$DashCoolDown.start()


func _on_AttackRange_body_exited(body: Node) -> void:
	_move_dir = Vector2.ZERO
	$DashCoolDown.stop()


# damaged
func _on_HurtBox_area_entered(area: Area2D) -> void:
	call_deferred("free")
