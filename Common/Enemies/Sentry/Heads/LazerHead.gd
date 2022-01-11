#--------------------------------------#
# LazerHead Script                     #
#--------------------------------------#
extends StaticBody2D

class_name LazerHead


# Variables:
#---------------------------------------
var _can_rotate := true
var _can_fire := false

onready var _parent := get_parent()

onready var _charge_timer := $Timer
onready var _laser_ray := $RayCast2D
onready var _laser_bream := $LaserBeam
onready var _tracking_line := $TrackingLine
onready var _hitbox = $LaserBeam/HitBox
onready var _hitbox_shape = $LaserBeam/HitBox/CollisionShape2D


# Functions:
#---------------------------------------
func _ready() -> void:
	_charge_timer.wait_time = 0.1 if (_charge_timer.wait_time + _parent.fire_delay < 0) else (_charge_timer.wait_time + _parent.fire_delay)
	
	_laser_ray.cast_to.x = _parent.attack_range
	_tracking_line.points[1] = _laser_ray.cast_to


func _physics_process(delta: float) -> void:
	if _parent.target:
		if _charge_timer.time_left == 0.0 and _can_rotate:
			_charge_timer.start()
		
		var target_dir = _parent.target.global_position - self.global_position
		
		if target_dir.dot(_parent.up_dir) > 0 and _parent.target_ray.get_collider() == _parent.target:
			_can_fire = true
			_tracking_line.visible = true
			
			if _can_rotate:
				rotation = _parent.target_angle
			
		else:
			_can_fire = false
			_tracking_line.visible = false
	
	# adjusting laser and tracking line visuals
	update_laser_visuals()


func update_laser_visuals() -> void:
	if _laser_ray.is_colliding():
		_tracking_line.points[1] = to_local(_laser_ray.get_collision_point())
		
		if _laser_bream.visible:
			_laser_bream.points[1] = to_local(_laser_ray.get_collision_point())
			_hitbox_shape.shape.extents.x = _laser_bream.points[1].x / 2
			_hitbox.position.x = _laser_bream.points[1].x / 2
		
	else:
		_tracking_line.points[1] = _laser_ray.cast_to
		
		if _laser_bream.visible:
			_laser_bream.points[1] = _laser_ray.cast_to
			_hitbox_shape.shape.extents.x = _laser_bream.points[1].x / 2
			_hitbox.position.x = _laser_bream.points[1].x / 2


func _on_Timer_timeout() -> void:
	if _can_fire:
		_can_rotate = false
		
		_laser_bream.visible = true
		_hitbox.monitorable = true
		
		yield(get_tree().create_timer(2), "timeout")
		
		_hitbox.monitorable = false
		_laser_bream.visible = false
		
		_can_rotate = true
		
	_charge_timer.start()

