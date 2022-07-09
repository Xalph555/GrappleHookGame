#--------------------------------------#
# PlayerUIManager Script               #
#--------------------------------------#
extends CanvasLayer
class_name PlayerUIManager


# Signals:
#---------------------------------------


# Variables:
#---------------------------------------
export(NodePath) onready var player_ref = get_node(player_ref) as Player

# UIs
export(NodePath) onready var mouse_aim_pointer_ui = get_node(mouse_aim_pointer_ui) as MouseAimPointer

export(NodePath) onready var gun_config_ui = get_node(gun_config_ui) as GunConfigUI
export(NodePath) onready var gun_upgrade_selection_ui = get_node(gun_upgrade_selection_ui) as GunUpgradeSelectionUI


# Functions:
#---------------------------------------
func _ready() -> void:
	yield(get_tree(), "idle_frame")


	set_up_gun_config_ui()
	set_up_gun_upgrade_selection_ui()
	set_up_mouse_aim_pointer_ui()


func set_up_mouse_aim_pointer_ui() -> void:
	mouse_aim_pointer_ui.set_up_ui(player_ref)


func set_up_gun_config_ui() -> void:
	gun_config_ui.set_up_ui(player_ref, player_ref.gun_extension, 3)


func set_up_gun_upgrade_selection_ui() -> void:
	gun_upgrade_selection_ui.set_up_ui(player_ref, player_ref.gun_extension, 3)
