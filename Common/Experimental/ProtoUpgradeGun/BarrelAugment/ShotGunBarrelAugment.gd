#--------------------------------------#
# ShotGunBarrelAugment Script          #
#--------------------------------------#

extends GunBarrelAugmentBase


# Variables:
#---------------------------------------
export(float) var projecilte_spread := 15.0
export(int) var num_projectiles := 4

var _rng = RandomNumberGenerator.new()


# Functions:
#---------------------------------------
func _ready() -> void:
	_rng.randomize() 


func shoot(spawn_pos : Vector2) -> void:
	.shoot(spawn_pos)

	var _shoot_dir = (parent.aim_location - parent.global_position).normalized()
	var _knock_dir = (gun_owner.global_position - parent.aim_location).normalized()
	
	for _i in range(num_projectiles):
		var _p_instance = projectile.instance()
		_p_instance.set_as_toplevel(true)
		add_child(_p_instance)
		
		var _speed = _rng.randf_range(parent.projectile_speed * 0.5, parent.projectile_speed)
		var _spread = _rng.randf_range(-projecilte_spread, projecilte_spread)
		var _new_dir = _shoot_dir.rotated(deg2rad(_spread))
		
		_p_instance.shoot(_new_dir, spawn_pos, _speed, parent.damage, parent.projectile_knock_back)
	
	gun_owner.velocity += _knock_dir * parent.knock_back
	
	parent.current_ammo -= 1
