#--------------------------------------#
# PlayerStats Script                   #
#--------------------------------------#
extends Node


# Signals:
#---------------------------------------
signal health_changed(health)
signal player_died

signal score_changed(score)


# Variables:
#---------------------------------------
export var max_health := 1

var score := 0 setget set_score

onready var current_health := max_health setget set_health


# Functions:
#---------------------------------------
func set_health(value: int) -> void:
	current_health = clamp(value, 0, max_health)
	emit_signal("health_changed", current_health)
	
	if current_health <= 0:
		emit_signal("player_died")
		
		print("Player has died")


func set_score(value: int) -> void:
	score = value
	emit_signal("score_changed", score)
