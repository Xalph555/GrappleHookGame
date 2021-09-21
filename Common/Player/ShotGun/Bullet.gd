#--------------------------------------#
# Bullet Script                        #
#--------------------------------------#

extends Area2D

# Variables
#---------------------------------------
var move_speed := 0
var direction := Vector2.ZERO
var velocity := Vector2.ZERO


# Functions:
#---------------------------------------
func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	velocity = direction * move_speed
	position += velocity * delta


func shoot(dir, start_pos, speed_var) -> void:
	move_speed = speed_var
	direction = dir
	self.global_position = start_pos



# Signals Connections:
#-------------------------------------
func _on_Timer_timeout() -> void:
	queue_free()


func _on_Bullet_area_entered(_area: Area2D) -> void:
	queue_free()
