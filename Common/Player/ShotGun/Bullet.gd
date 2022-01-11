#--------------------------------------#
# Bullet Script                        #
#--------------------------------------#
extends Area2D
class_name Bullet


# Variables
#---------------------------------------
var _move_speed := 0
var _direction := Vector2.ZERO
var _velocity := Vector2.ZERO


# Functions:
#---------------------------------------
func _physics_process(delta: float) -> void:
	_velocity = _direction * _move_speed
	position += _velocity * delta


func shoot(dir, start_pos, speed_var) -> void:
	_move_speed = speed_var
	_direction = dir
	self.global_position = start_pos



# Signals Connections:
#-------------------------------------
func _on_Timer_timeout() -> void:
	call_deferred("free")


func _on_Bullet_area_entered(_area: Area2D) -> void:
	call_deferred("free")


func _on_Bullet_body_entered(body: Node) -> void:
	call_deferred("free")
