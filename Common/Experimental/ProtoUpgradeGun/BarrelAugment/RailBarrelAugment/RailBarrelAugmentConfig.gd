#--------------------------------------#
# RailBarrelAugmentConfig Script       #
#--------------------------------------#
extends GunUpgradeConfig


# Variables:
#---------------------------------------
export(Resource) var rail_shell_res

export(float) var rail_beam_length
export(float) var rail_beam_width

export(Array, int) var collision_hit_masks
