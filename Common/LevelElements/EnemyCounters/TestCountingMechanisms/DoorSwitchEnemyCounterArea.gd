# test enemy counter door switch

extends Node2D


export(Array, NodePath) var door_paths
export var is_open := false

var _doors : Array

onready var enemy_counter := $EnemyCounterArea
onready var count_label := $EnemyCount


func _ready() -> void:
	for path in door_paths:
		_doors.append(get_node(path))
	
	call_deferred("_set_up_doors")
	call_deferred("_set_up_counter")


func _set_up_counter() -> void:
	enemy_counter.connect("total_count_changed", self, "_on_total_count_changed")
	enemy_counter.connect("defeated_count_changed", self, "_on_defeated_count_changed")
	enemy_counter.connect("all_enemies_defeated", self, "_on_all_enemies_defeated")


func _set_up_doors() -> void:
	for i in _doors:
		i.call_deferred("disable_trigger")
		i.call_deferred("set_default_state", is_open)


func trigger_door() -> void:
	if is_open:
		for i in _doors:
			i.open_door()
	
	else:
		for i in _doors:
			i.close_door()


# call backs
func _on_total_count_changed(new_total) -> void:
	count_label.text = str(enemy_counter.get_defeated_enemies()) + "/" + str(new_total)

func _on_defeated_count_changed(current_count) -> void:
	count_label.text = str(current_count) + "/" + str(enemy_counter.get_total_enemies())

func _on_all_enemies_defeated() -> void:
	is_open = !is_open
	trigger_door()
