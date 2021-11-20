extends StaticBody2D


export(bool) var is_main_portal = false
export(Array, NodePath) var portal_con_paths
#export(NodePath) var switch_path

export var exit_force := 300

var portal_connections : Array

var is_exiting := false

onready var exit_dir: Vector2 = ($ExitDirection.global_position - global_position).normalized()
#onready var portal_connection: StaticBody2D = get_node(portal_con_path)


func _ready() -> void:
	for i in range(portal_con_paths.size()):
		portal_connections.append(get_node(portal_con_paths[i]))


func set_is_exiting(exiting: bool) -> void:
	is_exiting = exiting
	
	for i in range(portal_connections.size()):
		portal_connections[i].is_exiting = exiting


func teleport_target(target: Node) -> void:
	var enter_dir = target.velocity.normalized()
	var exit_angle = enter_dir.angle_to(portal_connections[0].exit_dir)
	var exit_impulse = portal_connections[0].exit_dir * exit_force
	
	target.global_position = portal_connections[0].global_position
	target.velocity = target.velocity.rotated(exit_angle) + exit_impulse


func _on_EnterArea_body_entered(body: Node) -> void:
	if is_exiting:
		if is_main_portal: 
			set_is_exiting(false) 
		else: 
			portal_connections[0].set_is_exiting(false) 
	
	else:
		if is_main_portal:
			set_is_exiting(true)
		else:
			portal_connections[0].set_is_exiting(true)
			
		teleport_target(body)
