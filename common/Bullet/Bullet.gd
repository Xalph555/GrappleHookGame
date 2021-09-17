extends KinematicBody2D


var direction := Vector2.ZERO
var decel := 0.0
var velocity = Vector2.ZERO
var temp = true

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if temp:
		print(position)
		temp = false
	if move_and_collide(velocity * delta):
		self.queue_free()
	
	if velocity.length() < 10:
		self.queue_free()
	
	velocity *= 1 - decel * delta

func init(shooter, direction: Vector2, move_speed: float, decel: float = 0) -> KinematicBody2D:
	velocity = direction.normalized() * move_speed
	position = shooter.global_position
	self.decel = decel
	return self
