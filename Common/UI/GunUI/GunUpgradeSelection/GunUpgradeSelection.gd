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
func set_up_ui(gun_ref : ProtoGunExtension, num_of_slots : int) -> void:
	# create upgrade slots
	for i in range(num_of_slots):
		var slot_instance = upgrade_slot.instance()
		_slot_container.add_child(slot_instance)

		slot_instance.display_upgrade(i + 1, null)
		
		upgrade_slot_instances.append(slot_instance)

	# connect signals from gun
	gun_ref.connect("attribute_upgrade_changed", self, "_on_attribute_upgrade_changed")


func display_attached_upgrades(selected_upgrade : String) -> void:
	# , upgrades : Dictionary


	# for instance in upgrade_slot_instances:
	# 	instance.call_deferred("free")
	
	# upgrade_slot_instances.clear()

	# self.visible = true

	# _selection_name.text = selected_upgrade

	# for i in range(upgrades["AttributeUpgrades"].size()):
	# 	var slot_instance = upgrade_slot.instance()
	# 	_slot_container.add_child(slot_instance)

	# 	slot_instance.display_upgrade(i + 1, upgrades["AttributeUpgrades"][i].upgrade_icon)
		
	# 	upgrade_slot_instances.append(slot_instance)
	
	# new way of displaying
	_selection_name.text = selected_upgrade
	self.visible = true


func hide_attached_upgrades() -> void:
	self.visible = false

			
# gun signal call backs
func _on_attribute_upgrade_changed(slot : int, new_upgrade : GunUpgradeResource) -> void:
	if slot > upgrade_slot_instances.size():
		print("Invalid slot changed for GunUpgradeSelectionUI")
		return
	
	upgrade_slot_instances[slot - 1].update_icon(new_upgrade.upgrade_icon)
