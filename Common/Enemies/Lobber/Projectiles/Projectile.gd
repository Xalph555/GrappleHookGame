#--------------------------------------#
# Projectile Script                    #
#--------------------------------------#
extends RigidBody2D

class_name Projectile


# Variables:
#---------------------------------------
export (float) var gravity = 1000

var _hasCollided := false


# Functions:
#---------------------------------------
func _on_body_entered(body: Node) -> void:
	if !_hasCollided:
		_hasCollided = true
		
		yield(get_tree().create_timer(1.3), "timeout")
		call_deferred("free")


func _on_LifeTime_timeout() -> void:
	call_deferred("free")
