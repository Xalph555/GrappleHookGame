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
func set_up_barrel(new_parent, new_owner, new_projectile) -> void:
	.add_upgrade(new_parent, new_owner)

	self.projectile = new_projectile


func change_projectile(new_projectile) -> void:
	if self.projectile:
		remove_projectile()
	
	self.projectile = new_projectile


func remove_projectile() -> void:
	self.projectile = null


func shoot(spawn_pos : Vector2) -> void:
	if not self.projectile:
		print("Gun barrel has no projectile")
		return


func get_class() -> String:
	return "GunBarrelAugmentBase"
	

func is_class(value) -> bool:
	return value == "GunBarrelAugmentBase"