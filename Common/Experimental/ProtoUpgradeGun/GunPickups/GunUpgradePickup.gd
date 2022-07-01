#--------------------------------------#
# GunUpgradePickup Script              #
#--------------------------------------#
extends RigidBody2D
class_name GunUpgradePickup


# Variables:
#---------------------------------------
export(Resource) var upgrade

onready var _pick_up_text := $PickUpText


# Functions:
#---------------------------------------
func _ready() -> void:
	if upgrade:
		self.name = "Pick up: " + upgrade.get_name()
		_pick_up_text.text = upgrade.display_name

	highlight_pickup(false)
	

func get_compatability() -> Array:
	return []


func highlight_pickup(is_highlighted : bool) -> void:
	_pick_up_text.visible = is_highlighted


func get_class() -> String:
	return "GunUpgradePickup"

func is_class(value) -> bool:
	return value == "GunUpgradePickup"