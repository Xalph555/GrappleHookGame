#--------------------------------------#
# GunConfigUI Script                   #
#--------------------------------------#
extends Control


# Variables:
#---------------------------------------
export(PackedScene) var _slot

var _slot_instances := []

onready var _attribute_slots := $AttributeUpgrades/AttributeUpgradeSlots
onready var _barrel_slot := $BarrelUpgrade
onready var _projectile_slot := $Projectile


# Functions:
#---------------------------------------
func display_menu(upgrades : Dictionary) -> void:
	for instance in _slot_instances:
		instance.call_deferred("free")
	
	_slot_instances.clear()

	self.visible = true