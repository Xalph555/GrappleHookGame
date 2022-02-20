#--------------------------------------#
# Mouse Pointer Script                 #
#--------------------------------------#
extends Control


# Functions:
#---------------------------------------
func _process(delta: float) -> void:
	if !Input.is_action_pressed("ui_mouse_left"):
		self.set_rotation((get_global_mouse_position() - self.rect_global_position).angle())
		self.get_child(0).visible = true
		
	else:
		self.get_child(0).visible = false
