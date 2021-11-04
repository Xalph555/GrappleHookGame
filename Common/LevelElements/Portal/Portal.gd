extends StaticBody2D


export(NodePath) var portal_con_path
#export(NodePath) var switch_path

var is_exiting := false
var exit_force := 1500

var exit_angle_debug

var target: Node

onready var exit_dir: Vector2 = ($ExitDirection.global_position - global_position).normalized()
onready var portal_connection: StaticBody2D = get_node(portal_con_path)



func _on_EnterArea_body_entered(body: Node) -> void:
	if is_exiting:
		is_exiting = false
		portal_connection.is_exiting = false
	
	else:
		is_exiting = true
		portal_connection.is_exiting = true
		
		target = body
		
		var enter_dir = target.velocity.normalized()
		var exit_angle = enter_dir.angle_to(portal_connection.exit_dir)
		var exit_impulse = portal_connection.exit_dir * exit_force
		
		target.global_position = portal_connection.global_position
		target.velocity = target.velocity.rotated(exit_angle) + exit_impulse
		
		exit_angle_debug = rad2deg(exit_angle)
