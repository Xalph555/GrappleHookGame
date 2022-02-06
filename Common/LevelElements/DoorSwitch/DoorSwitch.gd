#--------------------------------------#
# DoorSwitch Script                  #
#--------------------------------------#
extends StaticBody2D

class_name DoorSwitch


# Variables:
#---------------------------------------
export(Array, NodePath) var door_paths

export var can_toggle := false
export var is_open := false

var _doors : Array

var _has_triggered := false

onready var _anim_player := $AnimationPlayer
onready var _toggle_cooldown := $ToggleCooldown
onready var _sprite := $Sprite


# Functions:
#---------------------------------------
func _ready() -> void:
	# get all connected portals
	for i in range(door_paths.size()):
		_doors.append(get_node(door_paths[i]))
	
	call_deferred("set_doors")
	set_sprite()


func set_doors() -> void:
	for i in _doors:
		i.call_deferred("disable_trigger")
		i.call_deferred("set_default_state", is_open)


func set_sprite() -> void:
	if is_open:
		_anim_player.play("SwitchOff")

	else:
		_anim_player.play("SwitchOn")
		


func trigger_doors() -> void:
	if is_open:
		for i in _doors:
			i.open_door()
	
	else:
		for i in _doors:
			i.close_door()


func _on_TriggerArea_area_entered(area: Area2D) -> void:
	if _toggle_cooldown.get_time_left() > 0:
		return
	
	if can_toggle:
		is_open = !is_open
		trigger_doors()
		set_sprite()
		
		_toggle_cooldown.start()
		
		return
	
	if !_has_triggered:
		_has_triggered = true
		
		is_open = !is_open
		trigger_doors()
		set_sprite()
		
		_toggle_cooldown.start()

