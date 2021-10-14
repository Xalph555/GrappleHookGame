extends StaticBody2D

export var sentry_head : PackedScene
export var attack_range := 2000.0
export var fire_delay := 0.0

var head : StaticBody2D

var up_dir := Vector2.ZERO

var target : Node = null
var target_angle := 0.0

onready var head_spawn_pos := $Position2D
onready var target_ray := $TargetRay
onready var attack_area := $AttackRange/CollisionShape2D


func _ready() -> void:
	up_dir = head_spawn_pos.global_position - self.global_position
	target_ray.cast_to.x = attack_range
	attack_area.shape.radius = attack_range
	
	# spawn choosen head
	var _head = sentry_head.instance()
	_head.position = head_spawn_pos.position
	add_child(_head)
	
	head = _head


func _physics_process(delta: float) -> void:
	if target:
		target_angle = (target.global_position - self.global_position).angle() - self.rotation
		target_ray.rotation = target_angle


func _on_AttackRange_body_entered(body: Node) -> void:
	target = body


func _on_AttackRange_body_exited(body: Node) -> void:
	target = null
