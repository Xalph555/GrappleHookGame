#--------------------------------------#
# Sentry Script                        #
#--------------------------------------#
extends StaticBody2D

class_name Sentry


# Variables:
#---------------------------------------
export var sentry_head : PackedScene
export var attack_range := 2000.0
export var fire_delay := 0.0

var up_dir := Vector2.ZERO

var target : Node = null
var target_angle := 0.0

var _head : StaticBody2D

onready var target_ray := $TargetRay
onready var _head_spawn_pos := $Position2D
onready var _attack_area := $AttackRange/CollisionShape2D


# Functions:
#---------------------------------------
func _ready() -> void:
	up_dir = _head_spawn_pos.global_position - self.global_position
	target_ray.cast_to.x = attack_range
	_attack_area.shape.radius = attack_range
	
	# spawn choosen head
	var _head_instance = sentry_head.instance()
	_head_instance.position = _head_spawn_pos.position
	add_child(_head_instance)
	
	_head = _head_instance


func _physics_process(delta: float) -> void:
	if target:
		target_angle = (target.global_position - self.global_position).angle() - self.rotation
		target_ray.rotation = target_angle


func _on_AttackRange_body_entered(body: Node) -> void:
	target = body


func _on_AttackRange_body_exited(body: Node) -> void:
	target = null
