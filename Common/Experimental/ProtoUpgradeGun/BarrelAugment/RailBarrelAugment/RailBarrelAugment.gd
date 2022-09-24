#--------------------------------------#
# RailBarrelAugment Script             #
#--------------------------------------#
extends GunBarrelAugmentBase


# Variables:
#---------------------------------------
var rail_shell_res 
var rail_beam_length := 100.0
var rail_beam_width := 100.0
var collision_hit_masks


# Functions:
#---------------------------------------
func config_upgrade(config : GunUpgradeConfig) -> void:
	.config_upgrade(config)

	rail_shell_res = config.rail_shell_res

	rail_beam_length = config.rail_beam_length
	rail_beam_width = config.rail_beam_width

	collision_hit_masks = config.collision_hit_masks


func set_up_barrel(new_parent, new_owner, new_projectile) -> void:
	.set_up_barrel(new_parent, new_owner, new_projectile)

	parent.change_projectile(rail_shell_res)


# func remove_upgrade() -> void:
# 	# need to remove current projectile from gun as well
# 	# also need to remove the raycast 2D - need to keep a reference to it
# 	pass


func shoot(spawn_pos : Vector2) -> void:
	# check if current projectile is the rail shell - if not, do not shoot 
	# after short delay - activate the ray cast for a bit - get all collisions
	# then do hits as required - looking for hurt box
	# also need to knock back player
	# shot has long duration - fling player back the entire time

	.shoot(spawn_pos)

	if self.projectile != rail_shell_res.projectile_scene:
		print("Incorrect projectile for rail barrel")
		return
	
	var _rail_shell_instance = projectile.instance()

	parent.spawn_pos.add_child(_rail_shell_instance)

	_rail_shell_instance.shoot(rail_beam_length, rail_beam_width, collision_hit_masks)

	var _knock_dir = (gun_owner.global_position - parent.aim_location).normalized()
	gun_owner.velocity += _knock_dir * parent.knock_back
	
	# parent.current_ammo -= 1

	print("rail gun has fired")
