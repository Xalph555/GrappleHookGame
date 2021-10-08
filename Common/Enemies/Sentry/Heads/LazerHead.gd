extends StaticBody2D

var target : Node = null
var can_rotate := true

onready var parent := get_parent()
onready var attack_area := $AttackRange/CollisionShape2D


func _ready() -> void:
	$Timer.wait_time = 0.1 if ($Timer.wait_time + parent.fire_delay < 0) else ($Timer.wait_time + parent.fire_delay)
	
	$RayCast2D.cast_to.y = -parent.attack_range
	$TrackingLine.points[1] = $RayCast2D.cast_to
	attack_area.shape.radius = parent.attack_range


func _physics_process(delta: float) -> void:
	if target != null and can_rotate:
		look_at(target.global_position)
		rotation += deg2rad(90)
		
	if $RayCast2D.is_colliding():
		$Line2D.points[1] = to_local($RayCast2D.get_collision_point())
		$TrackingLine.points[1] = to_local($RayCast2D.get_collision_point())
	else:
		$Line2D.points[1] = $RayCast2D.cast_to
		$TrackingLine.points[1] = $RayCast2D.cast_to
		
		# check to ensure not rotating past 180 degrees


func _on_Timer_timeout() -> void:
	can_rotate = false
	
	# fire laser + damage player
	$Line2D.visible = true
	yield(get_tree().create_timer(2), "timeout")
	$Line2D.visible = false

	can_rotate = true
	
	if target != null:
		$Timer.start()


func _on_AttackRange_body_entered(body: Node) -> void:
	$Timer.start()
	target = body
	$TrackingLine.visible = true


func _on_AttackRange_body_exited(body: Node) -> void:
	target = null
	$TrackingLine.visible = false
