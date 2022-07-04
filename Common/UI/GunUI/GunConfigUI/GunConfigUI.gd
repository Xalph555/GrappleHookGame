#--------------------------------------#
# GunConfigUI Script                   #
#--------------------------------------#
extends Control


# Variables:
#---------------------------------------
export(PackedScene) var upgrade_slot
export(PackedScene) var upgrade_slot_numbered

var _slot_instances := {"barrel" : null,
						"projectile" : null,
						"attributes" : []}

onready var _barrel_slot := $BarrelUpgrade
onready var _projectile_slot := $Projectile
onready var _attribute_slots := $AttributeUpgrades/AttributeUpgradeSlots


# Functions:
#---------------------------------------
func set_up_ui(gun_ref : ProtoGunExtension, num_of_upgrade_slots : int) -> void:
	# create upgrade slots
	var slot_instance = upgrade_slot.instance()
	_barrel_slot.add_child(slot_instance)
	_slot_instances["barrel"] = slot_instance

	slot_instance = upgrade_slot.instance()
	_projectile_slot.add_child(slot_instance)
	slot_instance["projectile"] = slot_instance

	for i in range(num_of_upgrade_slots):
		var slot_num_instance = upgrade_slot_numbered.instance()
		_attribute_slots.add_child(slot_num_instance)

		slot_num_instance.display_upgrade(i + 1, null)

		_slot_instances["attributed"].append(slot_instance)

	# connect signals
	gun_ref.connect("barrel_changed", self, "_on_barrel_changed")
	gun_ref.connect("projectile_changed", self, "_on_projectile_changed")
	gun_ref.connect("attribute_upgrade_changed", self, "_on_attribute_upgrade_changed")


func display_menu(upgrades : Dictionary) -> void:
	for instance in _slot_instances:
		instance.call_deferred("free")
	
	_slot_instances.clear()

	self.visible = true


func _on_barrel_changed(new_barrel : GunUpgradeResource):
	_slot_instances["barrel"].update_icon(new_barrel.upgrade_icon)


func _on_projectile_changed(new_projectile) -> void:
	pass


func _on_attribute_upgrade_changed(slot : int, new_upgrade : GunUpgradeResource) -> void:
	if slot > _slot_instances["attributes"].size():
		print("Invalid slot changed for GunUpgradeSelectionUI")
		return
	
	_slot_instances["attributes"][slot - 1].update_icon(new_upgrade.upgrade_icon)