#--------------------------------------#
# GunUpgradeSlotNumberedUI Script      #
#--------------------------------------#
extends VBoxContainer


# Signals:
#---------------------------------------
signal num_slot_double_clicked(number)


# Variables:
#---------------------------------------
var slot_number := 0

onready var _slot_num_text := $SlotNum
onready var _upgrade_icon := $CenterContainer/UpgradeIcon


# Functions:
#---------------------------------------
func display_upgrade(slot : int, upgrade_icon : Texture) -> void:
	slot_number = slot
	_slot_num_text.text = str(slot_number)

	update_icon(upgrade_icon)


func update_icon(upgrade_icon : Texture) -> void:
	_upgrade_icon.texture = upgrade_icon


func _on_UpgradeSlotNumbered_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.doubleclick:
			print("double clicked")
			emit_signal("num_slot_double_clicked", slot_number)
