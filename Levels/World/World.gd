extends Node2D

var player_start := Vector2.ZERO

onready var player := $Player

func _ready() -> void:
	player_start = player.global_position


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_home"):
		player.global_position = player_start
