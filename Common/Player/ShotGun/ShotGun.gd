#--------------------------------------#
# Shotgun Script                       #
#--------------------------------------#
extends Node2D
class_name Shotgun


# Variables:
#---------------------------------------
export var bullet: PackedScene

var _max_ammo := 3
var _current_ammo := _max_ammo

var _knock_back := 730.0

var _bullet_speed := 1000
var _bullet_spread := 15.0
var _num_bullets := 4

var _shot_delay := 0.3

var _rng := RandomNumberGenerator.new()

var _can_shoot := true

onready var _parent := get_parent()
onready var _tween := $Tween
onready var _pivot := $Pivot
onready var _sprite := $Pivot/Sprite
onready var _spawn_pos := $Pivot/BulletSpawn



# Functions:
#---------------------------------------
func _ready() -> void:
	_rng.randomize()


func _process(_delta: float) -> void:
	if _current_ammo > 0:
		look_at(get_global_mouse_position())
		rotation_degrees = wrapf(rotation_degrees, 0, 360)
	
	# flipping shotgun _sprite
	if rotation_degrees > 90 and rotation_degrees < 270:
		_pivot.scale.y = -1
	else:
		_pivot.scale.y = 1


func shoot() -> void:
	if _current_ammo > 0 and _can_shoot:
		var _shoot_dir = (get_global_mouse_position() - self.global_position).normalized()
		var _knock_dir = (get_global_mouse_position() - _parent.global_position).normalized()
		
		for _i in range(_num_bullets):
			var _bullet = bullet.instance() as Bullet
			#get_viewport().add_child(_bullet) # not sure if spawning on viewport is good idea
			_bullet.set_as_toplevel(true)
			add_child(_bullet)
			
			var _speed = _rng.randf_range(_bullet_speed * 0.5, _bullet_speed)
			var _spread = _rng.randf_range(-_bullet_spread, _bullet_spread)
			var _new_dir = _shoot_dir.rotated(deg2rad(_spread))
			
			_bullet.shoot(_new_dir, _spawn_pos.global_position, _speed)
		
		_parent.velocity -= _knock_dir * _knock_back
		
		_current_ammo -= 1
		if _current_ammo <= 0:
			reload()
		
		_can_shoot = false
		yield(get_tree().create_timer(_shot_delay), "timeout")
		_can_shoot = true


func reload():
	_tween.interpolate_property(self, "rotation", self.rotation, self.rotation + deg2rad(360), 0.5, Tween.TRANS_SINE,Tween.EASE_IN)
	_tween.start()
	yield(_tween, "tween_completed")
	_current_ammo = _max_ammo
