#----------------------------------------#
# UpgradeSlotNumberedUISelectable Script #
#----------------------------------------#
extends UpgradeSlotNumberedUI


# Signals:
#---------------------------------------
signal num_slot_double_clicked(number)


# Functions:
#---------------------------------------
func _on_TextureRect_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.doubleclick:
			emit_signal("num_slot_double_clicked", slot_number)
