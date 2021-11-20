extends StaticBody2D

var can_rotate := true
var can_fire := false

onready var parent := get_parent()

onready var charge_timer := $Timer
onready var laser_ray := $RayCast2D
onready var laser_bream := $LaserBeam
onready var tracking_line := $TrackingLine
onready var hit_box = $LaserBeam/HitBox
onready var hit_box_shape = $LaserBeam/HitBox/CollisionShape2D


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
		tracking_line.points[1] = to_local(laser_ray.get_collision_point())
		
		if laser_bream.visible:
			laser_bream.points[1] = to_local(laser_ray.get_collision_point())
			hit_box_shape.shape.extents.x = laser_bream.points[1].x / 2
			hit_box.position.x = laser_bream.points[1].x / 2
		
	else:
		tracking_line.points[1] = laser_ray.cast_to
		
		if laser_bream.visible:
			laser_bream.points[1] = laser_ray.cast_to
			hit_box_shape.shape.extents.x = laser_bream.points[1].x / 2
			hit_box.position.x = laser_bream.points[1].x / 2


func _on_Timer_timeout() -> void:
	if can_fire:
		can_rotate = false
		
		laser_bream.visible = true
		hit_box.monitorable = true
		
		yield(get_tree().create_timer(2), "timeout")
		
		hit_box.monitorable = false
		laser_bream.visible = false
		
		can_rotate = true
		
	charge_timer.start()

