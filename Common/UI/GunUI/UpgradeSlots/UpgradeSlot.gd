#--------------------------------------#
# GunUpgradeSlotUI Script              #
#--------------------------------------#
extends CenterContainer


# Signals:
#---------------------------------------
signal num_slot_double_clicked


# Variables:
#---------------------------------------
onready var _upgrade_icon := $UpgradeIcon


# Functions:
#---------------------------------------
func update_icon(upgrade_icon : Texture) -> void:
	_upgrade_icon.texture = upgrade_icon


func _on_UpgradeSlot_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.doubleclick:
			emit_signal("num_slot_double_clicked")
