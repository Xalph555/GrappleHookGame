#--------------------------------------#
# Mouse Pointer Script                 #
#--------------------------------------#
extends Control


# Functions:
#---------------------------------------
onready var _norm_pointer := $NormalPointer
onready var _dash_pointer := $DashPointer


# Functions:
#---------------------------------------
func _process(delta: float) -> void:
	self.set_rotation((get_global_mouse_position() - self.rect_global_position).angle())


func change_color(color : Color) -> void:
	self.modulate = color


func set_normal_pointer() -> void:
	_norm_pointer.visible = true
	_dash_pointer.visible = false


func set_dash_pointer() -> void:
	_norm_pointer.visible = false
	_dash_pointer.visible = true
