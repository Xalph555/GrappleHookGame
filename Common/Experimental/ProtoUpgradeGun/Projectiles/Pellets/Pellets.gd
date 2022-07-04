#--------------------------------------#
# Pellets Script                       #
#--------------------------------------#
extends Area2D
class_name Pellets


# Variables
#---------------------------------------
var _move_speed := 0.0
var _direction := Vector2.ZERO
var _velocity := Vector2.ZERO

onready var _hitbox := $HitBox as Hitbox


# Functions:
#---------------------------------------
func _physics_process(delta: float) -> void:
	position += _velocity * delta


func shoot(dir : Vector2, start_pos : Vector2, speed_var : float, damage : float, projectile_knock_back : float) -> void:
	_move_speed = speed_var
	_direction = dir
	self.global_position = start_pos

	_velocity = _direction * _move_speed

	_hitbox.damage = damage
	_hitbox.knock_back_force = projectile_knock_back


# Signals Connections:
#-------------------------------------
func _on_Timer_timeout() -> void:
	call_deferred("free")

func _on_Pellets_body_entered(_body:Node) -> void:
	call_deferred("free")

func _on_Pellets_area_entered(_area:Area2D) -> void:
	call_deferred("free")
