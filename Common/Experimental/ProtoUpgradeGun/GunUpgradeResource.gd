#--------------------------------------#
# GunUpgradeResource Script            #
#--------------------------------------#
tool

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

# export(Resource) var gun_upgrade_config : Resource
# export(Script) var gun_upgrade_script : Script

# export(PackedScene) var projectile_scene : PackedScene

export(Resource) var gun_incompatibilities

var gun_upgrade_config : Resource
var gun_upgrade_script : Script

var projectile_scene : PackedScene



# Functions:
#---------------------------------------
func get_class() -> String:
	return "GunUpgradeResource"

func is_class(value) -> bool:
	return value == "GunUpgradeResource"


func _get_property_list() -> Array:
	var props := []

	if gun_upgrade_type == GUN_UPGRADE_TYPES.PROJECTILE_UPGRADE:
		props.append({
			"name" : "projectile_scene",
			"type" : typeof(Resource),
			"hint" : PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string" : "PackedScene"
		})

		print("Hey")
	
	else:
		props.append({
			"name" : "gun_upgrade_config",
			"type" : typeof(Resource),
			"hint" : PROPERTY_HINT_RESOURCE_TYPE
		})
		props.append({
			"name" : "gun_upgrade_script",
			"type" : typeof(Script),
			"hint" : PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string" : "Script"
		})

		print("Yo")

	return props


func _set(property : String, value) -> bool:
	var res := true

	match property:
		"projectile_scene":
			projectile_scene = value
		
		"gun_upgrade_config":
			gun_upgrade_config = value
		
		"gun_upgrade_script":
			gun_upgrade_script = value
		
		_:
			res = false

	return res


func _get(property : String):
	match property:
		"projectile_scene":
			return projectile_scene
		
		"gun_upgrade_config":
			return gun_upgrade_config
		
		"gun_upgrade_script":
			return gun_upgrade_script

	return null

