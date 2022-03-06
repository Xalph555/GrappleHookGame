extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _line_width = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func draw_between(start: Vector2, end: Vector2):
	self.global_position = start
	self.region_rect.size.x = start.distance_to(end)
	self.rotation = self.global_position.angle_to_point(end) - self.rotation + deg2rad(180)

	
	
	
