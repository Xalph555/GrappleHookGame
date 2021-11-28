extends Area2D

var velocity : Vector2


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	velocity.y += gravity * delta
	position += velocity * delta
	rotation = velocity.angle()
