#--------------------------------------#
# Enemy Counter Base Script            #
#--------------------------------------#
extends Node

class_name EnemyCounterBase


# Signals:
#---------------------------------------
signal total_count_changed(new_total)
signal defeated_count_changed(current_count)
signal all_enemies_defeated


# Variables:
#---------------------------------------
var _total_enemies := 0
var _defeated_enemies := 0

var _enemies : Array


# Functions:
#---------------------------------------
# setting and clearing enemy array
func _clear_current_enemies() -> void:
	for enemy in _enemies:
		enemy.disconnect("tree_exited", self, "_on_enemy_defeated")
	
	_enemies.clear()
	
	print("_enemies array cleared")


func _set_enemy_connections() -> void:
	for enemy in _enemies:
		enemy.connect("tree_exited", self, "_on_enemy_defeated")


func reset_counter() -> void:
	set_total_enemies(_enemies.size())
	set_defeated_enemies(0)
	
	print("EnemyCounter Reset")


# getters and setters
func get_total_enemies() -> int:
	return _total_enemies

func set_total_enemies(enemy_count : int) -> void:
	if enemy_count < 0:
		print("Invalid enemy_count for set_total_enemies")
		return
	
	_total_enemies = enemy_count
	print("_total_enemies count changed")
	
	emit_signal("total_count_changed", _total_enemies)
	
	if _defeated_enemies >= _total_enemies:
		emit_signal("all_enemies_defeated")
		print("all enemies defeated for counter")

func get_defeated_enemies() -> int:
	return _defeated_enemies

func set_defeated_enemies(enemy_count : int) -> void:
	if enemy_count < 0:
		print("Invalid enemy_count for set_defeated_enemies")
		return
	
	_defeated_enemies = enemy_count
	print("_defeated_enemies count changed")
	
	emit_signal("defeated_count_changed", _defeated_enemies)
	
	if _defeated_enemies >= _total_enemies:
		emit_signal("all_enemies_defeated")
		print("all enemies defeated for counter")

func get_enemies() -> Array:
	return _enemies

func set_enemies(enemies : Array) -> void:
	_clear_current_enemies()
	
	_enemies = enemies
	set_total_enemies(_enemies.size())
	
	_set_enemy_connections()
	print("enemies array has been set")


# Signals Call backs:
#-------------------------------------
func _on_enemy_defeated() -> void:
	if (not get_tree()):
		return
		
	yield(get_tree(), "idle_frame")
	
	# clearing the destroyed enemy
	for i in range(_enemies.size()):
		if not is_instance_valid(_enemies[i]):
			_enemies.remove(i)
			
			set_defeated_enemies(get_defeated_enemies() + 1)
			
			print("enemy has been defeated - incremeting defeated count")
			break

