#--------------------------------------#
# GunBarrelBase Script                 #
#--------------------------------------#
extends GunUpgradeBase
class_name GunBarrelAugmentBase


# Variables:
#---------------------------------------
var projectile : PackedScene


# Functions:
#---------------------------------------
func set_up_barrel(new_parent, new_owner, new_projectile) -> bool:
	.add_upgrade(new_parent, new_owner)

	self.projectile = new_projectile

	return true


func change_projectile(new_projectile : PackedScene) -> bool:
	if self.projectile:
		remove_projectile()
	
	self.projectile = new_projectile

	return true


func remove_projectile() -> bool:
	self.projectile = null

	return true


func shoot(spawn_pos : Vector2) -> bool:
	if not self.projectile:
		print("Gun barrel has no projectile")
		return false

	return true


func get_class() -> String:
	return "GunBarrelAugmentBase"
	

func is_class(value) -> bool:
	return value == "GunBarrelAugmentBase"