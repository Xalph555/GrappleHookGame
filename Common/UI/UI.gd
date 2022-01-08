extends Control

# format node paths like this to make it more flexible
#export(NodePath) onready var _dialog_text = get_node(_dialog_text) as Label

export(NodePath) onready var _health_text = get_node(_health_text) as Label
export(NodePath) onready var _score_text = get_node(_score_text) as Label
export(NodePath) onready var _mouse_pointer = get_node(_mouse_pointer) as Control

export var boss_hp_bar: PackedScene

var _temp_nodes = []


func _ready() -> void:
	# connect signals
	GameEvents.connect("boss_fight_start", self, "_on_boss_fight_start")
	GameEvents.connect("boss_fight_end", self, "_on_boss_fight_end")
	
	PlayerStats.connect("health_changed", self, "_on_health_updated")
	PlayerStats.connect("score_changed", self, "_on_score_updated")
	
	# starting values
	_health_text.text = "Health: " + str(PlayerStats.current_health)


func _process(delta: float) -> void:
	update_aim_indicator()


func update_aim_indicator() -> void:
	if !Input.is_action_pressed("ui_mouse_left"):
		_mouse_pointer.set_rotation((get_local_mouse_position() - _mouse_pointer.rect_position).angle())
		_mouse_pointer.get_child(0).visible = true
		
	else:
		_mouse_pointer.get_child(0).visible = false


func _on_health_updated(current_health: int) -> void:
	_health_text.text = "Health: " + str(current_health)


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
