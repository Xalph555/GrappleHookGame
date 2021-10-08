extends StaticBody2D

export var sentry_head : PackedScene
export var attack_range := 4200.0
export var fire_delay := 0.0


func _ready() -> void:
	var _head = sentry_head.instance()
	_head.position = $Position2D.position
	add_child(_head)


func _physics_process(delta: float) -> void:
	pass
