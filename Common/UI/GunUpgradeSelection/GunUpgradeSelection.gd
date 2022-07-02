#--------------------------------------#
# GunUpgradeSelection UI Script        #
#--------------------------------------#
extends Control


# Variables:
#---------------------------------------
export(PackedScene) var upgrade_slot

var upgrade_slot_instances := []

onready var _selection_name := $VBoxContainer/UpgradeName
onready var _slot_container := $VBoxContainer/UpgradeSlotContainer


# Functions:
#---------------------------------------
func display_attached_upgrades(selected_upgrade : String, upgrades : Dictionary) -> void:
	for instance in upgrade_slot_instances:
		instance.call_deferred("free")
	
	upgrade_slot_instances.clear()

	self.visible = true

	_selection_name.text = selected_upgrade

	for i in range(upgrades["AttributeUpgrades"].size()):
		var slot_instance = upgrade_slot.instance()
		_slot_container.add_child(slot_instance)

		slot_instance.display_upgrade(i + 1, upgrades["AttributeUpgrades"][i].upgrade_icon)
		
		upgrade_slot_instances.append(slot_instance)


func hide_attached_upgrades() -> void:
	self.visible = false

			
