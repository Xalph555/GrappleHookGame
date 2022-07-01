#--------------------------------------#
# GunUpgradeConfig Script              #
#--------------------------------------#
extends Resource
class_name GunUpgradeConfig


# Variables:
#---------------------------------------
export(int) var ammo := 0

export(float) var reload_speed := 0.0
export(float) var fire_rate := 0.0

export(float) var knock_back := 0.0
export(float) var damage := 0.0
export(float) var projectile_knock_back := 0.0
export(float) var projectile_speed := 0.0


# Functions:
#---------------------------------------
func get_class() -> String:
	return "GunUpgradeConfig"

func is_class(value) -> bool:
	return value == "GunUpgradeConfig"