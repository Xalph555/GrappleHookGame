#--------------------------------------#
# ProtoGunExtension Script             #
#--------------------------------------#
extends Node2D
class_name ProtoGunExtension


# Signals:
#---------------------------------------
signal max_ammo_changed(new_max_ammo)
signal current_ammo_changed(new_current_ammo)
signal reloading
signal reloaded

signal reload_speed_changed(new_reload_speed)
signal fire_rate_changed(new_fire_rate)

signal knock_back_changed(new_knock_back)
signal damage_changed(new_damage)
signal projectile_knock_back_changed(new_knock_back)
signal bullet_speed_changed(new_bullet_speed)


# Variables:
#---------------------------------------
# upgrade pickup template
export(PackedScene) var pickup_template

# default variables
export(PackedScene) var default_projectile
export(PackedScene) var default_barrel_augment
export(PackedScene) var default_attribute_upgrade1
export(PackedScene) var default_attribute_upgrade2
export(PackedScene) var default_attribute_upgrade3

export(float) var default_reload_speed := 0.0
export(float) var default_fire_rate := 0.0
export(float) var default_knock_back := 100.0
export(float) var default_base_damage := 2.0
export(float) var default_projectile_knock_back := 0.0
export(float) var default_base_projectile_speed := 500.0

# references to components
var current_projectile : PackedScene
var current_barrel_augment : GunBarrelAugmentBase
var current_attribute_upgrades = {1 : null,
								  2 : null,
								  3 : null}

# base stats
var base_max_ammo := 0 setget set_base_max_ammo, get_base_max_ammo

onready var base_reload_speed := default_reload_speed setget set_base_reload_speed, get_base_reload_speed
onready var base_fire_rate := default_fire_rate setget set_base_fire_rate, get_base_fire_rate

onready var base_knock_back := default_knock_back setget set_base_knock_back, get_base_knock_back
onready var base_damage := default_base_damage setget set_base_damage, get_base_damage
onready var base_projectile_knock_back := default_projectile_knock_back setget set_base_projectile_knock_back, get_base_projectile_knock_back
onready var base_projectile_speed := default_base_projectile_speed setget set_base_projectile_speed, get_base_projectile_speed

# stat modifiers
var max_ammo_mod := 0

var reload_speed_mod := 0.0
var fire_rate_mod := 0.0

var knock_back_mod := 0.0
var damage_mod := 0.0
var projectile_knock_back_mod = 0.0
var projectile_speed_mod := 0.0

# total stats
var max_ammo := 0 setget set_max_ammo, get_max_ammo
var current_ammo := 0 setget set_current_ammo, get_current_ammo

var reload_speed := 0.0 setget set_reload_speed, get_reload_speed
var fire_rate := 0.0 setget set_fire_rate, get_fire_rate

var knock_back := 0.0 setget set_knock_back, get_knock_back
var damage := 0.0 setget set_damage, get_damage
var projectile_knock_back := 0.0 setget set_projectile_knock_back, get_projectile_knock_back
var projectile_speed := 0.0 setget set_projectile_speed, get_projectile_speed

# other
var aim_location : Vector2
var _can_shoot := true

# node references
var gun_owner

onready var components := $Components

onready var _tween := $Tween
onready var _pivot := $Pivot
onready var _sprite := $Pivot/Sprite
onready var _spawn_pos := $Pivot/BulletSpawn

onready var _fire_rate_timer := $FireRateTimer
onready var _reload_timer := $ReloadTimer


# Functions:
#---------------------------------------
func set_up(new_gun_owner) -> void:
	gun_owner = new_gun_owner
	restore_defaults()
	

func _process(_delta: float) -> void:
	# gun aim
	aim_location = get_global_mouse_position()

	if self.current_ammo > 0:
		look_at(aim_location)
		rotation_degrees = wrapf(rotation_degrees, 0, 360)
	
	# flipping _sprite
	if rotation_degrees > 90 and rotation_degrees < 270:
		_pivot.scale.y = -1
	else:
		_pivot.scale.y = 1


func shoot() -> void:
	if not current_barrel_augment or not current_projectile:
		return

	if self.current_ammo > 0 and _can_shoot:
		_can_shoot = false
		current_barrel_augment.shoot(_spawn_pos.global_position)

		if self.current_ammo <= 0:
			reload()

		else:
			_fire_rate_timer.start()


func reload() -> void:
	emit_signal("reloading")

	_tween.interpolate_property(self, "rotation", 
								self.rotation, self.rotation + deg2rad(360), 
								(base_reload_speed + reload_speed_mod), Tween.TRANS_SINE,Tween.EASE_IN)
	_tween.start()
	_reload_timer.start()


func restore_defaults() -> void:
	self.base_reload_speed = default_reload_speed
	self.base_fire_rate = default_fire_rate
	
	self.base_knock_back = default_knock_back
	self.base_damage = default_base_damage
	self.base_projectile_speed = default_base_projectile_speed

	# setting up defaults for gun components
	assert(default_barrel_augment, "default barrel augment not set")
	attach_barrel(default_barrel_augment)

	assert(default_projectile, "default projectile not set")
	change_projectile(default_projectile)
	
	if default_attribute_upgrade1:
		attach_upgrade(1, default_attribute_upgrade1)
	
	if default_attribute_upgrade2:
		attach_upgrade(2, default_attribute_upgrade2)
	
	if default_attribute_upgrade3:
		attach_upgrade(3, default_attribute_upgrade3)

	_can_shoot = true


func refresh_stats() -> void:
	self.max_ammo += 0
	self.current_ammo += 0

	self.reload_speed += 0
	self.fire_rate += 0

	self.knock_back += 0
	self.damage += 0
	self.projectile_speed += 0

	_can_shoot = true


func change_projectile(new_projectile : PackedScene) -> void:
	if not new_projectile:
		print("Invalid projectile being set for gun")
		return
	
	if current_projectile:
		remove_projectile()

	current_projectile = new_projectile
	current_barrel_augment.change_projectile(current_projectile)


func attach_barrel(barrel : PackedScene) -> void:
	if not barrel:
		print("Invalid barrel being set for gun")
		return
	
	if current_barrel_augment:
		detach_barrel()
		

	current_barrel_augment = barrel.instance()
	components.add_child(current_barrel_augment)

	current_barrel_augment.set_up_barrel(self, gun_owner, current_projectile)


func attach_upgrade(slot : int, upgrade : PackedScene) -> void:
	if not upgrade:
		print("Invalid upgrade being set for gun")
		return
	
	if slot < 0 or slot > 3:
		print("Invalid upgrade slot chosen for gun")
		return

	if current_attribute_upgrades[slot]:
		detach_upgrade(slot)
		
	
	current_attribute_upgrades[slot] = upgrade.instance()
	components.add_child(current_attribute_upgrades[slot])

	current_attribute_upgrades[slot].add_upgrade(self, gun_owner)


func remove_projectile() -> void:
	# eject current projectile
	if current_barrel_augment:
		current_barrel_augment.remove_projectile()

	current_projectile = null


func detach_barrel() -> void:
	current_barrel_augment.remove_upgrade()
	eject_upgrade(current_barrel_augment)

	current_barrel_augment.call_deferred("free")
	current_barrel_augment = null


func detach_upgrade(slot : int) -> void:
	current_attribute_upgrades[slot].remove_upgrade()
	eject_upgrade(current_attribute_upgrades[slot])

	current_attribute_upgrades[slot].call_deferred("free")
	current_attribute_upgrades[slot] = null


func eject_upgrade(upgrade) -> void:
	var packed_upgrade = PackedScene.new()
	packed_upgrade.pack(upgrade)

	var new_pickup = pickup_template.instance()

	new_pickup.upgrade = packed_upgrade
	new_pickup.upgrade_type = upgrade.get_class()
	new_pickup.display_name = upgrade.display_name

	new_pickup.global_position = self.global_position

	get_tree().current_scene.add_child(new_pickup)

	new_pickup.apply_central_impulse(Vector2.UP * 120)


func get_free_upgrade_slot() -> int:
	if current_attribute_upgrades[1] == null:
		return 1
	
	if current_attribute_upgrades[2] == null:
		return 2

	if current_attribute_upgrades[3] == null:
		return 3

	return -1


func check_compatability(prohibitions : Array) -> bool:
	return false


# timer callbacks
func _on_ReloadTimer_timeout() -> void:
	_fire_rate_timer.stop()

	self.current_ammo = self.max_ammo
	_can_shoot = true

	emit_signal("reloaded")


func _on_FireRateTimer_timeout() -> void:
	if _reload_timer.time_left > 0:
		return

	_can_shoot = true


# base stats getters and setters
func get_base_max_ammo() -> int:
	return base_max_ammo

func set_base_max_ammo(value)-> void:
	if value >= 0:
		base_max_ammo = value
		self.max_ammo += 0

func get_base_reload_speed() -> float:
	return base_reload_speed

func set_base_reload_speed(value)-> void:
	if value >= 0:
		base_reload_speed = value
		self.reload_speed += 0

func get_base_fire_rate() -> float:
	return base_fire_rate

func set_base_fire_rate(value)-> void:
	if value >= 0:
		base_fire_rate = value
		self.fire_rate += 0

func get_base_knock_back() -> float:
	return base_knock_back

func set_base_knock_back(value)-> void:
	if value >= 0:
		base_knock_back = value
		self.knock_back += 0

func get_base_damage() -> float:
	return base_damage

func set_base_damage(value)-> void:
	if value >= 0:
		base_damage = value
		self.damage += 0

func get_base_projectile_knock_back() -> float:
	return base_damage

func set_base_projectile_knock_back(value)-> void:
	if value >= 0:
		base_projectile_knock_back = value
		self.projectile_knock_back += 0

func get_base_projectile_speed() -> float:
	return base_projectile_speed

func set_base_projectile_speed(value)-> void:
	if value >= 0:
		base_projectile_speed = value
		self.projectile_speed += 0

# stats getters and setters
func get_max_ammo() -> int:
	return max_ammo

func set_max_ammo(value)-> void:
	value = int(value)

	max_ammo_mod += value - max_ammo
	max_ammo = int(max(0, base_max_ammo + max_ammo_mod))

	self.current_ammo = max_ammo

	emit_signal("max_ammo_changed", max_ammo)

func get_current_ammo() -> int:
	return current_ammo

func set_current_ammo(value)-> void:
	value = int(value)

	current_ammo = int(max(0, value))

	emit_signal("current_ammo_changed", current_ammo)

func get_reload_speed() -> float:
	return reload_speed

func set_reload_speed(value)-> void:
	reload_speed_mod += value - reload_speed
	reload_speed = max(0.001, base_reload_speed + reload_speed_mod)

	_reload_timer.wait_time = reload_speed

	emit_signal("reload_speed_changed", reload_speed)
		
func get_fire_rate() -> float:
	return fire_rate

func set_fire_rate(value)-> void:
	fire_rate_mod += value - fire_rate
	fire_rate = max(0.001, base_fire_rate + fire_rate_mod)

	_fire_rate_timer.wait_time = fire_rate

	emit_signal("fire_rate_changed", fire_rate)

func get_knock_back() -> float:
	return knock_back

func set_knock_back(value)-> void:
	knock_back_mod += value - knock_back
	knock_back = max(0.0, base_knock_back + knock_back_mod)

	emit_signal("knock_back_changed", knock_back)

func get_damage() -> float:
	return damage

func set_damage(value)-> void:
	damage_mod += value - damage
	damage = max(0.0, base_damage + damage_mod)

	emit_signal("damage_changed", damage)

func get_projectile_knock_back() -> float:
	return projectile_knock_back

func set_projectile_knock_back(value)-> void:
	projectile_knock_back_mod += value - projectile_knock_back
	projectile_knock_back = max(0.0, base_projectile_knock_back + projectile_knock_back_mod)

	emit_signal("projectile_knock_back_changed", projectile_knock_back)

func get_projectile_speed() -> float:
	return projectile_speed

func set_projectile_speed(value)-> void:
	projectile_speed_mod += value - projectile_speed
	projectile_speed = max(0.0, base_projectile_speed + projectile_speed_mod)

	emit_signal("bullet_speed_changed", projectile_speed)