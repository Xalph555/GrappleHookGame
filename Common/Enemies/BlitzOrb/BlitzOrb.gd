extends KinematicBody2D


var hover_dist := 1200
var target : Node = null

var move_speed := 3000
var move_dir := Vector2.ZERO
var velocity := Vector2.ZERO

var is_attacking := false

var rng := RandomNumberGenerator.new()



func _ready() -> void:
	rng.randomize()
	var dash_offset = rng.randf_range(0, 1)
	$DashCoolDown.wait_time += dash_offset


func _physics_process(delta: float) -> void:
	if target != null:
		if !is_attacking:
			state_idle()
		
		velocity = move_speed * move_dir
		velocity = move_and_slide(velocity)


func state_idle() -> void:
	var vector_to_target : Vector2 = target.global_position - self.global_position 
	
	if vector_to_target.length() > hover_dist * 1.1:
		move_dir = vector_to_target.normalized()
	
	elif vector_to_target.length() < hover_dist * 0.9:
		move_dir = -vector_to_target.normalized()
	
	else:
		move_dir = Vector2.ZERO


func dash_attack() -> void:
	$AnimationPlayer.play("Flash")
	yield($AnimationPlayer, "animation_finished")
	
	$CollisionShape2D.disabled = true
	$Trail.visible = true
	is_attacking = true
	var vector_to_target : Vector2 = target.global_position - self.global_position 
	move_dir = vector_to_target.normalized()
	move_speed *= 1.8
	yield(get_tree().create_timer(0.5), "timeout")
	
	move_dir = Vector2.ZERO
	move_speed /= 1.8
	
	yield(get_tree().create_timer(0.1), "timeout")
	is_attacking = false
	$Trail.visible = false
	$CollisionShape2D.disabled = false
	$DashCoolDown.start()


func _on_DashCoolDown_timeout() -> void:
	dash_attack()


func _on_AttackRange_body_entered(body: Node) -> void:
	target = body
	$DashCoolDown.start()


func _on_AttackRange_body_exited(body: Node) -> void:
	#target = null
	move_dir = Vector2.ZERO
	$DashCoolDown.stop()
