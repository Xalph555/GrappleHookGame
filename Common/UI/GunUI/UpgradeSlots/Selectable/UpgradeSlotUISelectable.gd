#--------------------------------------#
# GunUpgradeSlotUISelectable Script    #
#--------------------------------------#
extends UpgradeSlotUI


# Signals:
#---------------------------------------
signal num_slot_double_clicked


# Functions:
#---------------------------------------
func _on_SlotIcon_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.doubleclick:
			_slot_icon.material.set_shader_param("intensity", 0)
			emit_signal("num_slot_double_clicked")


func _on_SlotIcon_mouse_entered() -> void:
	if _upgrade_icon.texture != null:
		_slot_icon.material.set_shader_param("intensity", 200)


func _on_SlotIcon_mouse_exited() -> void:
	_slot_icon.material.set_shader_param("intensity", 0)
