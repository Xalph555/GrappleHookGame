#--------------------------------------#
# GunUpgradeSlotNumberedUI Script      #
#--------------------------------------#
extends VBoxContainer
class_name UpgradeSlotNumberedUI


# Variables:
#---------------------------------------
var slot_number := 0

onready var _slot_num_text := $SlotNum
onready var _slot_icon := $CenterContainer/SlotIcon
onready var _upgrade_icon := $CenterContainer/UpgradeIcon


# Functions:
#---------------------------------------
func display_upgrade(slot : int, upgrade_icon : Texture) -> void:
	slot_number = slot
	_slot_num_text.text = str(slot_number)

	update_icon(upgrade_icon)


func update_icon(upgrade_icon : Texture) -> void:
	_upgrade_icon.texture = upgrade_icon


