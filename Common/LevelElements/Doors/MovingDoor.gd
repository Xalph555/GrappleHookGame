#--------------------------------------#
# Moving Door Script                   #
#--------------------------------------#
extends Path2D

class_name MovingDoor


# Variables:
#---------------------------------------
export(float) var door_speed := 0.6
export(bool) var default_opened := false
export(bool) var is_one_shot := true
export(bool) var can_rotate := true

var _current_unit_offset := 0.0
var _is_opened := false
var _has_moved := false

onready var _path_follow := $PathFollow2D
onready var _tween := $Tween
onready var _trigger_area := $TriggerArea


# Functions:
#---------------------------------------
func _ready() -> void:
	_path_follow.rotate = can_rotate
	set_default_state(default_opened)


func _process(delta: float) -> void:
	_current_unit_offset = _path_follow.unit_offset


func open_door() -> void:
	_tween.interpolate_property(_path_follow, "unit_offset", 
								_current_unit_offset, 1, 
								door_speed, 
								Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	_tween.start()
	
	_is_opened = true


func close_door() -> void:
	_tween.interpolate_property(_path_follow, "unit_offset", 
								_current_unit_offset, 0, 
								door_speed, 
								Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	_tween.start()
	
	_is_opened = false


func set_default_state(opened : bool) -> void:
	if opened:
		_path_follow.unit_offset = 1
	
	else:
		_path_follow.unit_offset = 0
	
	_is_opened = opened
	
	# resetting default_opened in case a switch is connected to it
	default_opened = opened


func disable_trigger() -> void:
	_trigger_area.disable_trigger()


func _on_TriggerArea_body_entered(body: Node) -> void:
	if not _has_moved:
		if default_opened:
			close_door()
		
		else:
			open_door()
	
	if is_one_shot:
		_has_moved = true


func _on_TriggerArea_body_exited(body: Node) -> void:
	if not _has_moved:
		if default_opened:
			open_door()
		
		else:
			close_door()
	
	if is_one_shot:
		_has_moved = true
