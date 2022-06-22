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
var total_enemies := 0 setget set_total_enemies, get_total_enemies
var defeated_enemies := 0 setget set_defeated_enemies, get_defeated_enemies

var enemies := [] setget set_enemies, get_enemies


# Functions:
#---------------------------------------
# setting and clearing enemy array
func _clear_current_enemies() -> void:
	for enemy in self.enemies:
		enemy.disconnect("tree_exited", self, "_on_enemy_defeated")
	
	self.enemies.clear()
	
	print("enemies array cleared")


func _set_enemy_connections() -> void:
	for enemy in self.enemies:
		enemy.connect("tree_exited", self, "_on_enemy_defeated")


func reset_counter() -> void:
	self.total_enemies = self.enemies.size()
	self.defeated_enemies = 0
	
	print("EnemyCounter Reset")


# getters and setters
func get_total_enemies() -> int:
	return total_enemies

func set_total_enemies(enemy_count : int) -> void:
	if enemy_count < 0:
		print("Invalid enemy_count for set_total_enemies")
		return
	
	total_enemies = enemy_count
	print("total_enemies count changed")
	
	emit_signal("total_count_changed", total_enemies)
	
	if self.defeated_enemies >= total_enemies:
		emit_signal("all_enemies_defeated")
		print("all enemies defeated for counter")

func get_defeated_enemies() -> int:
	return defeated_enemies

func set_defeated_enemies(enemy_count : int) -> void:
	if enemy_count < 0:
		print("Invalid enemy_count for set_defeated_enemies")
		return
	
	defeated_enemies = enemy_count
	print("defeated_enemies count changed")
	
	emit_signal("defeated_count_changed", defeated_enemies)
	
	if defeated_enemies >= self.total_enemies:
		emit_signal("all_enemies_defeated")
		print("all enemies defeated for counter")

func get_enemies() -> Array:
	return enemies

func set_enemies(enemies_in : Array) -> void:
	_clear_current_enemies()
	
	enemies = enemies_in
	self.total_enemies = enemies.size()
	
	_set_enemy_connections()
	print("enemies array has been set")


# Signals Call backs:
#-------------------------------------
func _on_enemy_defeated() -> void:
	if (not get_tree()):
		return
		
	yield(get_tree(), "idle_frame")
	
	# clearing the destroyed enemy
	for i in range(self.enemies.size()):
		if not is_instance_valid(self.enemies[i]):
			self.enemies.remove(i)
			
			self.defeated_enemies += 1
			
			print("enemy has been defeated - incremeting defeated count")
			break

