#--------------------------------------#
# UI Script                            #
#--------------------------------------#
extends Control


# Variables:
#---------------------------------------
export(NodePath) onready var _health_text = get_node(_health_text) as Label
export(NodePath) onready var _ammo_text = get_node(_ammo_text) as Label
export(NodePath) onready var _score_text = get_node(_score_text) as Label

export var boss_hp_bar: PackedScene

var _temp_nodes = []


# Functions:
#---------------------------------------
func _ready() -> void:
	# connect signals
	GameEvents.connect("boss_fight_start", self, "_on_boss_fight_start")
	GameEvents.connect("boss_fight_end", self, "_on_boss_fight_end")
	
	PlayerStats.connect("health_changed", self, "_on_health_updated")
	PlayerStats.connect("ammo_changed", self, "_on_ammo_updated")
	PlayerStats.connect("score_changed", self, "_on_score_updated")
	
	# starting values
	_health_text.text = "Health: " + str(PlayerStats.current_health)


func _on_health_updated(current_health: int) -> void:
	_health_text.text = "Health: " + str(current_health)


func _on_ammo_updated(current_ammo: int, max_ammo: int) -> void:
	_ammo_text.text = "Ammo: " + str(current_ammo) + "/" + str(max_ammo)


func _on_score_updated(current_score: int) -> void:
	_score_text.text = "Score: " + str(current_score)


func _on_boss_fight_start(boss_ref) -> void:
	var _health_bar_instance := boss_hp_bar.instance()
	
	add_child(_health_bar_instance)
	_temp_nodes.append(_health_bar_instance)
	
	_health_bar_instance.init(boss_ref)


func _on_boss_fight_end() -> void:
	for i in range(_temp_nodes.size() - 1, -1, -1):
		if _temp_nodes[i] is BossHealthBar:
			var _temp_health_bar = _temp_nodes[i]
			_temp_nodes.remove(i)
			_temp_health_bar.call_deferred("free")
