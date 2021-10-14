#--------------------------------------#
# ShotGun Script                       #
#--------------------------------------#

extends Node2D

# Variables:
#---------------------------------------
export var bullet: PackedScene

var max_ammo := 3
var current_ammo := max_ammo

var knock_back := 2800.0

var bullet_speed := 3000
var bullet_spread := 15.0
var num_bullets := 4

var shot_delay := 0.3

var rng := RandomNumberGenerator.new()

var can_shoot := true

onready var parent := get_parent()
onready var tween := $Tween
onready var sprite := $Sprite
onready var spawn_pos := $BulletSpawn



# Functions:
#---------------------------------------
func _ready() -> void:
	rng.randomize()


func _process(_delta: float) -> void:
	if current_ammo > 0:
		look_at(get_global_mouse_position())


func shoot() -> void:
	if current_ammo > 0 and can_shoot:
		var shoot_dir = (get_global_mouse_position() - self.global_position).normalized()
		var knock_dir = (get_global_mouse_position() - parent.global_position).normalized()
		
		for _i in range(num_bullets):
			var _bullet := bullet.instance()
			get_viewport().add_child(_bullet) # not sure if spawning on viewport is good idea
			
			var speed = rng.randf_range(bullet_speed * 0.5, bullet_speed)
			var spread = rng.randf_range(-bullet_spread, bullet_spread)
			var new_dir = shoot_dir.rotated(deg2rad(spread))
			
			_bullet.shoot(new_dir, spawn_pos.global_position, speed)
		
		parent.velocity -= knock_dir * knock_back
		
		current_ammo -= 1
		if current_ammo <= 0:
			reload()
		
		can_shoot = false
		yield(get_tree().create_timer(shot_delay), "timeout")
		can_shoot = true


func reload():
	tween.interpolate_property(self, "rotation", self.rotation, self.rotation + deg2rad(360), 0.5, Tween.TRANS_SINE,Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	current_ammo = max_ammo
