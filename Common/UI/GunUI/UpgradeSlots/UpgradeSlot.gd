#--------------------------------------#
# GunUpgradeSlotUI Script              #
#--------------------------------------#
extends CenterContainer


# Variables:
#---------------------------------------
onready var _upgrade_icon := $UpgradeIcon


# Functions:
#---------------------------------------
func update_icon(upgrade_icon : Texture) -> void:
	_upgrade_icon.texture = upgrade_icon