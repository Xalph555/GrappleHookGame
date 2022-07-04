#--------------------------------------#
# GunIncompatibilitiesResource Script  #
#--------------------------------------#
extends Resource
class_name GunIncompatibilitiesResource

# Variables:
#---------------------------------------
export(Array, Resource) var barrels
export(Array, Resource) var projectiles
export(Array, Resource) var attribute_upgrades


# Functions:
#---------------------------------------
func get_class() -> String:
	return "GunIncompatibilitiesResource"

func is_class(value) -> bool:
	return value == "GunIncompatibilitiesResource"