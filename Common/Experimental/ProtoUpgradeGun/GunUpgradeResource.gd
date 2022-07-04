#--------------------------------------#
# GunUpgradeResource Script            #
#--------------------------------------#
extends Resource
class_name GunUpgradeResource


# Variables:
#---------------------------------------
export(String) var display_name = ""

enum GUN_UPGRADE_TYPES {ATTRIBUTE_UPGRADE,
						BARREL_UPGRADE,
						PROJECTILE_UPGRADE}
export(GUN_UPGRADE_TYPES) var gun_upgrade_type

export(Texture) var upgrade_icon

export(Resource) var gun_upgrade_config
export(Script) var gun_upgrade_script

export(PackedScene) var projectile_scene

export(Resource) var gun_incompatibilities


# Functions:
#---------------------------------------
func get_class() -> String:
	return "GunUpgradeResource"

func is_class(value) -> bool:
	return value == "GunUpgradeResource"
