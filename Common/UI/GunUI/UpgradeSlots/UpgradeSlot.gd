#--------------------------------------#
# GunUpgradeSlotUI Script              #
#--------------------------------------#
extends CenterContainer
class_name UpgradeSlotUI


# Variables:
#---------------------------------------
onready var _upgrade_icon := $UpgradeIcon
onready var _slot_icon := $SlotIcon


# Functions:
#---------------------------------------
func update_icon(upgrade_icon : Texture) -> void:
	_upgrade_icon.texture = upgrade_icon
