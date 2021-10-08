extends StaticBody2D

export var attack_range := 2000.0

var target : Node = null
var can_rotate := true

onready var head := $Head
onready var head_raycast := $Head/RayCast2D
onready var laserbeam := $Head/RayCast2D/Line2D
onready var attack_area := $AttackRange/CollisionShape2D


func _ready() -> void:
	head_raycast.cast_to.y = -attack_range
	attack_area.shape.radius = attack_range


func _physics_process(delta: float) -> void:
	if target != null and can_rotate:
		head.look_at(target.global_position)
		head.rotation += deg2rad(90)
		
	if head_raycast.is_colliding():
		laserbeam.points[1] = to_local(head_raycast.get_collision_point())
	else:
		laserbeam.points[1] = head_raycast.cast_to
		
		# check to ensure not rotating past 180 degrees


func _on_Timer_timeout() -> void:
	can_rotate = false
	
	# fire laser + damage player
	laserbeam.visible = true
	yield(get_tree().create_timer(2), "timeout")
	laserbeam.visible = false

	can_rotate = true
	$Timer.start()


func _on_AttackRange_body_entered(body: Node) -> void:
	$Timer.start()
	target = body


func _on_AttackRange_body_exited(body: Node) -> void:
	$Timer.stop()
	target = null
