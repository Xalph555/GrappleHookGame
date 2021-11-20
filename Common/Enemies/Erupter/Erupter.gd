extends StaticBody2D

export var fire_delay := 0.0

var limit := Vector2.ZERO

onready var anim_player := $AnimationPlayer
onready var timer := $Timer

onready var ray_cast := $RayCast2D
onready var eruption_beam := $RayCast2D/Line2D
onready var hit_box := $RayCast2D/HitBox
onready var hit_box_shape := $RayCast2D/HitBox/CollisionShape2D


func _ready() -> void:
	timer.wait_time = 0.1 if (timer.wait_time + fire_delay < 0) else (timer.wait_time + fire_delay)


func _physics_process(delta: float) -> void:
	# get limit of beam
	if ray_cast.is_colliding():
		limit = to_local(ray_cast.get_collision_point())
		ray_cast.enabled = false
	
	# set size of line and hitbox
	eruption_beam.points[1] = limit
	hit_box_shape.shape.extents.y = limit.y / 2
	hit_box.position.y = limit.y / 2


func _on_Timer_timeout() -> void:
	anim_player.play("fire_beam")
	yield(anim_player, "animation_finished")
	timer.start()
