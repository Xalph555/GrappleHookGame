#--------------------------------------#
# GunUpgradeSlot UI Script             #
#--------------------------------------#
extends VBoxContainer


# Variables:
#---------------------------------------
onready var _slot_num := $SlotNum
onready var _upgrade_icon := $CenterContainer/UpgradeIcon


# Functions:
#---------------------------------------
func display_upgrade(slot : int, upgrade_icon : Texture) -> void:
	_slot_num.text = str(slot)

	_upgrade_icon.texture = upgrade_icon
