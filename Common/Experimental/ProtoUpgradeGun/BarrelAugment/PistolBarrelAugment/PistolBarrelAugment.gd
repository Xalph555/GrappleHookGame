#--------------------------------------#
# PistolBarrelAugment Script           #
#--------------------------------------#
extends GunBarrelAugmentBase


# Functions:
#---------------------------------------
func shoot(spawn_pos : Vector2) -> void:
	.shoot(spawn_pos)

	var _shoot_dir = (parent.aim_location - parent.global_position).normalized()
	var _knock_dir = (gun_owner.global_position - parent.aim_location).normalized()

	var _p_instance = projectile.instance()
	_p_instance.set_as_toplevel(true)
	add_child(_p_instance)
	
	_p_instance.shoot(_shoot_dir, spawn_pos, parent.projectile_speed, parent.damage, parent.projectile_knock_back)

	gun_owner.velocity += _knock_dir * parent.knock_back
	
	parent.current_ammo -= 1
