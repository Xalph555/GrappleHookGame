#--------------------------------------#
# Projectile Script                    #
#--------------------------------------#
extends RigidBody2D

class_name Projectile


# Variables:
#---------------------------------------
export (float) var gravity = 1000

var _has_collided := false

onready var _life_timer := $LifeTime


# Functions:
#---------------------------------------
func _on_body_entered(body: Node) -> void:
	if !_has_collided:
		_has_collided = true
		
		_life_timer.stop()
		yield(get_tree().create_timer(1.3), "timeout")
		call_deferred("free")


func _on_LifeTime_timeout() -> void:
	call_deferred("free")
