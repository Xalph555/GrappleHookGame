#--------------------------------------#
# TransportPortal Script               #
#--------------------------------------#
extends StaticBody2D

class_name TransportPortal


# Variables:
#---------------------------------------
export(bool) var is_main_portal = false
export(Array, NodePath) var portal_con_paths

export var exit_force := 300

export var is_active_default := false

var is_exiting := false

var _portal_connections : Array

onready var exit_dir: Vector2 = ($ExitDirection.global_position - global_position).normalized()

onready var _enter_area_collision := $EnterArea/CollisionShape2D
onready var _portal_particles := $Particles2D


# Functions:
#---------------------------------------
func _ready() -> void:
	# set portal default active state
	toggle_portal(is_active_default)
	
	# get all connecting portals
	for i in range(portal_con_paths.size()):
		_portal_connections.append(get_node(portal_con_paths[i]))


func toggle_portal(is_active : bool) -> void:
	_enter_area_collision.disabled = not is_active
	_portal_particles.emitting = is_active


func set_is_exiting(exiting: bool) -> void:
	is_exiting = exiting
	
	for i in range(_portal_connections.size()):
		_portal_connections[i].is_exiting = exiting


func teleport_target(target: Node) -> void:
	var enter_dir = target.velocity.normalized()
	var exit_angle = enter_dir.angle_to(_portal_connections[0].exit_dir)
	var exit_impulse = _portal_connections[0].exit_dir * _portal_connections[0].exit_force
	
	target.global_position = _portal_connections[0].global_position
	target.velocity = target.velocity.rotated(exit_angle) + exit_impulse


func _on_EnterArea_body_entered(body: Node) -> void:
	if is_exiting:
		if is_main_portal: 
			set_is_exiting(false) 
		else: 
			_portal_connections[0].set_is_exiting(false) 
	
	else:
		if is_main_portal:
			set_is_exiting(true)
		else:
			_portal_connections[0].set_is_exiting(true)
			
		teleport_target(body)
