#--------------------------------------#
# TransportPortalSwitch Script         #
#--------------------------------------#
extends StaticBody2D

class_name TransportPortalSwitch


# Variables:
#---------------------------------------
export(Array, NodePath) var connected_portal_paths

export var can_toggle := false
export var is_active := false

var _connected_portals : Array

var _has_triggered := false

onready var _sprite := $Sprite
onready var _toggle_cooldown := $ToggleCooldown


# Functions:
#---------------------------------------
func _ready() -> void:
	# get all connected portals
	for i in range(connected_portal_paths.size()):
		_connected_portals.append(get_node(connected_portal_paths[i]))
	
	# set all connected portals to the appropriate state
	# call_deferred to allow the portals to properly load first
	call_deferred("set_portals")
	set_sprite()


func set_portals() -> void:
	for i in _connected_portals:
		i.call_deferred("toggle_portal", is_active)


func set_sprite() -> void:
	if is_active:
		_sprite.set_modulate(Color.slategray)
		
	else:
		_sprite.set_modulate(Color.royalblue)


func _on_TriggerArea_area_entered(area: Area2D) -> void:
	if _toggle_cooldown.get_time_left() > 0:
		return
	
	if can_toggle:
		is_active = !is_active
		set_portals()
		set_sprite()
		
		_toggle_cooldown.start()
		
		return
	
	if !_has_triggered:
		_has_triggered = true
		
		is_active = !is_active
		set_portals()
		set_sprite()
		
		_toggle_cooldown.start()


func _on_ToggleCooldown_timeout() -> void:
	pass # Replace with function body.
