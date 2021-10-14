extends StaticBody2D

var can_rotate := true
var can_fire := false

onready var parent := get_parent()

onready var charge_timer := $Timer
onready var laser_ray := $RayCast2D
onready var laser_bream := $LaserBeam
onready var tracking_line := $TrackingLine


func _ready() -> void:
	charge_timer.wait_time = 0.1 if (charge_timer.wait_time + parent.fire_delay < 0) else (charge_timer.wait_time + parent.fire_delay)
	
	laser_ray.cast_to.x = parent.attack_range
	tracking_line.points[1] = laser_ray.cast_to


func _physics_process(delta: float) -> void:
	if parent.target:
		if charge_timer.time_left == 0.0 and can_rotate:
			charge_timer.start()
		
		var target_dir = parent.target.global_position - self.global_position
		
		if target_dir.dot(parent.up_dir) > 0 and parent.target_ray.get_collider() == parent.target:
			can_fire = true
			tracking_line.visible = true
			
			if can_rotate:
				rotation = parent.target_angle
			
		else:
			can_fire = false
			tracking_line.visible = false
	
	# adjusting laser and tracking line visuals
	if laser_ray.is_colliding():
		laser_bream.points[1] = to_local(laser_ray.get_collision_point())
		tracking_line.points[1] = to_local(laser_ray.get_collision_point())
		
	else:
		laser_bream.points[1] = laser_ray.cast_to
		tracking_line.points[1] = laser_ray.cast_to


func _on_Timer_timeout() -> void:
	if can_fire:
		can_rotate = false
		
		laser_bream.visible = true
		yield(get_tree().create_timer(2), "timeout")
		laser_bream.visible = false
		
		can_rotate = true
		
	charge_timer.start()

