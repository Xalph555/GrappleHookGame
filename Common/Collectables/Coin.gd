extends Area2D

var points := 100


func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	yield(get_tree().create_timer(rng.randf_range(0, 1)), "timeout")
	$AnimationPlayer.play("Idle")


func _on_body_entered(body: Node) -> void:
	print("coin collected")
	queue_free()
