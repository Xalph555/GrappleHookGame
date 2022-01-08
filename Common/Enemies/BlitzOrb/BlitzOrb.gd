extends KinematicBody2D


var hover_dist := 180
var target : Node = null

var move_speed := 1010
var move_dir := Vector2.ZERO
var velocity := Vector2.ZERO

var max_dashes := 5
var current_dashes := max_dashes
var is_attacking := false

var rng := RandomNumberGenerator.new()

onready var hit_box = $HitBox


func _ready() -> void:
	rng.randomize()
	var dash_offset = rng.randf_range(0, 1)
	$DashCoolDown.wait_time += dash_offset


func _physics_process(delta: float) -> void:
	if target != null and current_dashes > 0:
		if !is_attacking:
			follow_target()
		
		velocity = move_speed * move_dir
		velocity = move_and_slide(velocity)
	
	else:
		$DashCoolDown.stop()


func follow_target() -> void:
	var dir_to_target: Vector2 = (target.global_position - self.global_position).normalized()
	var hover_point: Vector2 = target.global_position - (dir_to_target * hover_dist)
	
	global_position = lerp(global_position, hover_point, 0.1)


# this needs to be cleaned up
func dash_attack() -> void:
	$AnimationPlayer.play("flash")
	yield($AnimationPlayer, "animation_finished")
	set_attack(true)
	
	var vector_to_target : Vector2 = target.global_position - self.global_position 
	move_dir = vector_to_target.normalized()
	move_speed *= 1.8
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	move_dir = Vector2.ZERO
	move_speed /= 1.8
	
	yield(get_tree().create_timer(0.1), "timeout")
	set_attack(false)
	$DashCoolDown.start()
	current_dashes -= 1


func set_attack(attacking: bool) -> void:
	is_attacking = attacking
	hit_box.monitorable = attacking
	$Trail.visible = attacking
	$CollisionShape2D.disabled = attacking


func _on_DashCoolDown_timeout() -> void:
	dash_attack()


func _on_AttackRange_body_entered(body: Node) -> void:
	target = body
	$DashCoolDown.start()


func _on_AttackRange_body_exited(body: Node) -> void:
	move_dir = Vector2.ZERO
	$DashCoolDown.stop()


# damaged
func _on_HurtBox_area_entered(area: Area2D) -> void:
	queue_free()
