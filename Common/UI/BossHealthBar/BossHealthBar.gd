#--------------------------------------#
# BossHealthBar Script                 #
#--------------------------------------#
extends Control

class_name BossHealthBar


# Variables:
#---------------------------------------
export(NodePath) onready var _boss_name = get_node(_boss_name) as Label
export(NodePath) onready var _boss_health = get_node(_boss_health) as TextureProgress


# Functions:
#---------------------------------------
func init(boss_ref) -> void:
	_boss_name.text = boss_ref.name
	
	_boss_health.max_value = boss_ref.max_health
	_boss_health.value = _boss_health.max_value
	
	boss_ref.connect("boss_health_changed", self, "_on_boss_health_changed")


func _on_boss_health_changed(health) -> void:
	_boss_health.value = health
