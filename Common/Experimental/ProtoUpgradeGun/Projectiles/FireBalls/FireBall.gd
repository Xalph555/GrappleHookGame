#--------------------------------------#
# FireBalls Script                     #
#--------------------------------------#
extends RigidBody2D
class_name FireBalls


# Variables
#---------------------------------------
var _has_collided := false

onready var _life_timer := $LifeTimer
onready var _hitbox := $HitBox as Hitbox


# Functions:
#---------------------------------------
func shoot(dir : Vector2, start_pos : Vector2, speed_var : float, damage : float, projectile_knock_back : float) -> void:
	self.global_position = start_pos

	self.linear_velocity = dir * (speed_var)

	_hitbox.damage = damage
	_hitbox.knock_back_force = projectile_knock_back


func destroy_fire_ball() -> void:
	if !_has_collided:
		_has_collided = true
		
		_life_timer.stop()
		yield(get_tree().create_timer(1.3), "timeout")
		call_deferred("free")


# Signals Connections:
#-------------------------------------
func _on_LifeTimer_timeout() -> void:
	call_deferred("free")

func _on_HitBox_area_entered(area:Area2D) -> void:
	destroy_fire_ball()

func _on_HitBox_body_entered(body:Node) -> void:
	destroy_fire_ball()
