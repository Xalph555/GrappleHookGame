extends Control

# format node paths like this to make it more flexible
#export(NodePath) onready var _dialog_text = get_node(_dialog_text) as Label

export(NodePath) onready var _health_text = get_node(_health_text) as Label
export(NodePath) onready var _score_text = get_node(_score_text) as Label
export(NodePath) onready var _mouse_pointer = get_node(_mouse_pointer) as Control


func _ready() -> void:
	# connect signals
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
