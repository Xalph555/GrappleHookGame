#--------------------------------------#
# GunUpgradeBase Script                #
#--------------------------------------#
extends Node
class_name GunUpgradeBase


# Variables:
#---------------------------------------
export(String) var display_name := ""

# stat modifiers
export(int) var ammo := 0

export(float) var reload_speed := 0.0
export(float) var fire_rate := 0.0

export(float) var knock_back := 0.0
export(float) var damage := 0.0
export(float) var projectile_knock_back := 0.0
export(float) var projectile_speed := 0.0

var parent
var gun_owner


# Functions:
#---------------------------------------
func add_upgrade(new_parent, new_owner) -> void:
	parent = new_parent
	gun_owner = new_owner

	parent.max_ammo += self.ammo

	parent.reload_speed += self.reload_speed
	parent.fire_rate += self.fire_rate

	parent.knock_back += self.knock_back
	parent.damage += self.damage
	parent.projectile_knock_back = self.projectile_knock_back
	parent.projectile_speed += self.projectile_speed


func remove_upgrade() -> void:
	parent.max_ammo -= self.ammo

	parent.reload_speed -= self.reload_speed
	parent.fire_rate -= self.fire_rate

	parent.knock_back -= self.knock_back
	parent.damage -= self.damage
	parent.projectile_knock_back -= self.projectile_knock_back
	parent.projectile_speed -= self.projectile_speed

	parent = null
	gun_owner = null


func get_class() -> String:
	return "GunUpgradeBase"

func is_class(value) -> bool:
	return value == "GunUpgradeBase"
