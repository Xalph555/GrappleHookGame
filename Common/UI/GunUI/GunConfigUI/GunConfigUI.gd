#--------------------------------------#
# GunConfigUI Script                   #
#--------------------------------------#
extends Control
class_name GunConfigUI


# Variables:
#---------------------------------------
export(PackedScene) var upgrade_slot
export(PackedScene) var upgrade_slot_numbered

var _slot_instances := {"barrel" : null,
						"projectile" : null,
						"attributes" : []}

var _player : Player
var _player_gun : ProtoGunExtension

var _is_active := false

onready var _barrel_slot := $BarrelUpgrade
onready var _projectile_slot := $Projectile
onready var _attribute_slots := $AttributeUpgrades/AttributeUpgradeSlots


# Functions:
#---------------------------------------
func set_up_ui(player_ref : Player, gun_ref : ProtoGunExtension, num_of_upgrade_slots : int) -> void:
	_player = player_ref
	_player_gun = gun_ref

	# create upgrade slots
	var slot_instance = upgrade_slot.instance()
	_barrel_slot.add_child(slot_instance)
	slot_instance.connect("num_slot_double_clicked", self, "_on_barrel_slot_double_clicked")
	_slot_instances["barrel"] = slot_instance

	slot_instance = upgrade_slot.instance()
	_projectile_slot.add_child(slot_instance)
	slot_instance.connect("num_slot_double_clicked", self, "_on_projectile_slot_double_clicked")
	_slot_instances["projectile"] = slot_instance

	for i in range(num_of_upgrade_slots):
		var slot_num_instance = upgrade_slot_numbered.instance()
		_attribute_slots.add_child(slot_num_instance)
		
		slot_num_instance.connect("num_slot_double_clicked", self, "_on_attribute_upgrade_slot_double_clicked")
		slot_num_instance.display_upgrade(i + 1, null)

		_slot_instances["attributes"].append(slot_num_instance)
	
	self.visible = _is_active

	# connect signals
	_player_gun.connect("barrel_changed", self, "_on_barrel_changed")
	_player_gun.connect("projectile_changed", self, "_on_projectile_changed")
	_player_gun.connect("attribute_upgrade_changed", self, "_on_attribute_upgrade_changed")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		display_menu(false)
		
	if event.is_action_pressed("tab"):
		display_menu(! _is_active)


func display_menu(shown : bool) -> void:
	_is_active = shown

	if _is_active:
		self.visible = true
	
	else:
		self.visible = false


# gun callbacks
func _on_barrel_changed(new_barrel : GunUpgradeResource):
	if new_barrel:
		_slot_instances["barrel"].update_icon(new_barrel.upgrade_icon)
	else:
		_slot_instances["barrel"].update_icon(null)

func _on_projectile_changed(new_projectile : GunUpgradeResource) -> void:
	if new_projectile:
		_slot_instances["projectile"].update_icon(new_projectile.upgrade_icon)
	else:
		_slot_instances["projectile"].update_icon(null)

func _on_attribute_upgrade_changed(slot : int, new_upgrade : GunUpgradeResource) -> void:
	if slot < 1 or slot > _slot_instances["attributes"].size():
		print("Invalid slot changed for GunUpgradeSelectionUI")
		return
	
	if new_upgrade:
		_slot_instances["attributes"][slot - 1].update_icon(new_upgrade.upgrade_icon)
	else:
		_slot_instances["attributes"][slot - 1].update_icon(null)


# UI callbacks
func _on_barrel_slot_double_clicked() -> void:
	_player_gun.detach_barrel()

func _on_projectile_slot_double_clicked() -> void:
	_player_gun.remove_projectile()

func _on_attribute_upgrade_slot_double_clicked(slot_num : int) -> void:
	_player_gun.detach_upgrade(slot_num)
