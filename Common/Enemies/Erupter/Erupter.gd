#--------------------------------------#
# Erupter Script                       #
#--------------------------------------#
extends StaticBody2D

class_name Erupter


# Variables:
#---------------------------------------
export var fire_delay := 0.0

var _limit := Vector2.ZERO

onready var _anim_player := $AnimationPlayer
onready var _timer := $Timer

onready var _ray_cast := $RayCast2D
onready var _eruption_beam := $RayCast2D/Line2D
onready var _hitbox := $RayCast2D/HitBox
onready var _hitbox_shape := $RayCast2D/HitBox/CollisionShape2D



# Functions:
#---------------------------------------
func _ready() -> void:
	_timer.wait_time = 0.1 if (_timer.wait_time + fire_delay < 0) else (_timer.wait_time + fire_delay)


func _physics_process(delta: float) -> void:
	# get limit of beam
	if _ray_cast.is_colliding():
		_limit = to_local(_ray_cast.get_collision_point())
		_ray_cast.enabled = false
	
	# set size of line and hitbox
	_eruption_beam.points[1] = _limit
	_hitbox_shape.shape.extents.y = _limit.y / 2
	_hitbox.position.y = _limit.y / 2


func _on_Timer_timeout() -> void:
	_anim_player.play("fire_beam")
	yield(_anim_player, "animation_finished")
	_timer.start()
