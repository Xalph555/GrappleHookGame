#--------------------------------------#
# Coin Script                          #
#--------------------------------------#
extends Collectable

class_name Coin


# Variables:
#---------------------------------------
var _points := 100


# Functions:
#---------------------------------------
func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	yield(get_tree().create_timer(rng.randf_range(0, 1)), "timeout")
	$AnimationPlayer.play("Idle")


func on_entered(body: Node) -> void:
	PlayerStats.score += _points
	queue_free()
