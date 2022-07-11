#--------------------------------------#
# GunUpgradeSelection UI Script        #
#--------------------------------------#
extends Control
class_name GunUpgradeSelectionUI


# Variables:
#---------------------------------------
export(PackedScene) var upgrade_slot

var upgrade_slot_instances := []

var _player : Player
var _player_gun : ProtoGunExtension

var _pending_upgrade : GunUpgradeResource

onready var _selection_name := $Control/VBoxContainer/UpgradeName
onready var _slot_container := $Control/VBoxContainer/UpgradeSlotContainer


# Functions:
#---------------------------------------
func set_up_ui(player_ref : Player, gun_ref : ProtoGunExtension, num_of_slots : int) -> void:
	_player = player_ref
	_player_gun = gun_ref

	# create upgrade slots
	for i in range(num_of_slots):
		var slot_instance = upgrade_slot.instance()
		_slot_container.add_child(slot_instance)

		slot_instance.connect("num_slot_double_clicked", self, "_on_attribute_upgrade_slot_double_clicked")
		slot_instance.display_upgrade(i + 1, null)
		
		upgrade_slot_instances.append(slot_instance)

	hide_attached_upgrades()

	# connect signals from plater
	_player.connect("pick_up_deselected", self, "_on_pick_up_deselected")

	# connect signals from gun
	_player_gun.connect("attribute_upgrade_changed", self, "_on_attribute_upgrade_changed")
	_player_gun.connect("attribute_slots_full", self, "_on_attribute_slots_full")


func _process(delta: float) -> void:
	rect_position = _player.get_global_transform_with_canvas().origin


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		hide_attached_upgrades()
	
	# attach upgrade to selected slot
	if event.is_action_pressed("selection1"):
		switch_upgrade(1)
	
	if event.is_action_pressed("selection2"):
		switch_upgrade(2)
	
	if event.is_action_pressed("selection3"):
		switch_upgrade(3) 


func display_attached_upgrades(pending_upgrade : GunUpgradeResource) -> void:
	_pending_upgrade = pending_upgrade

	_selection_name.text = _pending_upgrade.display_name
	self.visible = true

	set_process_unhandled_input(true)


func hide_attached_upgrades() -> void:
	self.visible = false
	_pending_upgrade = null
	set_process_unhandled_input(false)


func switch_upgrade(slot : int) -> void:
	_player_gun.attach_upgrade(slot, _pending_upgrade)
	_player.remove_selected_pickup() 

	hide_attached_upgrades() 
	

# player signal call back
func _on_pick_up_deselected(pick_up) -> void:
	if _pending_upgrade:
		hide_attached_upgrades()
			

# gun signal call backs
func _on_attribute_upgrade_changed(slot : int, new_upgrade : GunUpgradeResource) -> void:
	if slot < 1 or slot > upgrade_slot_instances.size():
		print("Invalid slot changed for GunUpgradeSelectionUI")
		return
	
	if new_upgrade:
		upgrade_slot_instances[slot - 1].update_icon(new_upgrade.upgrade_icon)
	else:
		upgrade_slot_instances[slot - 1].update_icon(null)


func _on_attribute_slots_full(upgrade : GunUpgradeResource) -> void:
	display_attached_upgrades(upgrade)


# UI call back
func _on_attribute_upgrade_slot_double_clicked(slot_num : int) -> void:
	switch_upgrade(slot_num) 

