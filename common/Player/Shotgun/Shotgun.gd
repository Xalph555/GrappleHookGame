extends Node2D

const BULLET = preload("res://common/Bullet/Bullet.tscn")
const NUM_BULLETS = 5
const ANGLE_SPREAD = 10.0
const MOVE_SPEED = 5000
const MOVE_SPREAD = 1000

var rng = RandomNumberGenerator.new()
onready var wielder: KinematicBody2D = get_parent()

func _ready():
	rng.randomize()


func fire_shotgun():
	var fire_dir = (get_global_mouse_position() - wielder.global_position).normalized()
	
	for i in range(NUM_BULLETS):
		# fire in the direction of the mouse + some random angle
		var spread = rng.randf_range(-ANGLE_SPREAD, ANGLE_SPREAD)
		var speed = MOVE_SPEED + rng.randf_range(-MOVE_SPREAD, 0.0)
		var new_dir = fire_dir.rotated(deg2rad(spread))
		
		print("SHOTGUN WIELDER: ", wielder.position)
		owner.add_child(BULLET.instance().init(wielder, new_dir, speed))
	
	
func _process(delta):
	print(wielder.position)
	if Input.is_action_just_pressed("ui_mouse_right"):
		fire_shotgun()
