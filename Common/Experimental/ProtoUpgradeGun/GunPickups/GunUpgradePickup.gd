#--------------------------------------#
# GunUpgradePickup Script              #
#--------------------------------------#

extends RigidBody2D
class_name GunUpgradePickup



# Variables:
#---------------------------------------
export(PackedScene) var upgrade
export(String) var upgrade_type
export(String) var display_name


onready var _pick_up_text := $PickUpText


# Functions:
#---------------------------------------
func _ready() -> void:
	if upgrade:
		self.name = "Pick up: " + upgrade.get_state().get_node_name(0)
		_pick_up_text.text = display_name

	highlight_pickup(false)
	

func get_upgrade() -> PackedScene:
	return upgrade


func get_upgrade_type() -> String:
	return upgrade_type


func get_compatability() -> Array:
	return []


func highlight_pickup(is_highlighted : bool) -> void:
	_pick_up_text.visible = is_highlighted


func get_class() -> String:
	return "GunUpgradePickup"

func is_class(value) -> bool:
	return value == "GunUpgradePickup"