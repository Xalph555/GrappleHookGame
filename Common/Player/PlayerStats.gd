#--------------------------------------#
# PlayerStats Script                   #
#--------------------------------------#
extends Node


# Signals:
#---------------------------------------
signal health_changed(health)
signal player_died

signal ammo_changed(c_ammo, m_ammo)

signal score_changed(score)


# Variables:
#---------------------------------------
export var max_health := 1
onready var current_health := max_health setget set_health

var max_ammo := 0
var current_ammo := max_ammo setget set_ammo

var score := 0 setget set_score

var _stored_stats = []

var _player_has_died = false


# Functions:
#---------------------------------------
func _ready() -> void:
	# storing current values
	_stored_stats.append(max_health)
	_stored_stats.append(current_health)
	_stored_stats.append(score)


func save_stats() -> void:
	_stored_stats[0] = max_health
	_stored_stats[1] = current_health
	_stored_stats[2] = score


func reload_stats() -> void:
	max_health = _stored_stats[0]
	current_health = _stored_stats[1]
	score = _stored_stats[2]


func set_health(value: int) -> void:
	current_health = clamp(value, 0, max_health)
	emit_signal("health_changed", current_health)
	
	if current_health <= 0 and not _player_has_died:
		emit_signal("player_died")
		_player_has_died = true
		
		print("Player has died")


func set_ammo(value: int) -> void:
	current_ammo = value
	emit_signal("ammo_changed", current_ammo, max_ammo)


func change_weapon(cur_ammo: int, m_ammo: int) -> void:
	max_ammo = m_ammo
	current_ammo = cur_ammo
	
	emit_signal("ammo_changed", current_ammo, max_ammo)


func set_score(value: int) -> void:
	score = value
	emit_signal("score_changed", score)
