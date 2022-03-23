#--------------------------------------#
# Chain Script                         #
#--------------------------------------#
extends Sprite


# Variables
#---------------------------------------
var _line_width = 10


# Functions:
#---------------------------------------
func draw_between(start: Vector2, end: Vector2):
	self.global_position = start
	self.region_rect.size.x = start.distance_to(end)
	self.rotation = self.global_position.angle_to_point(end) - self.rotation + deg2rad(180)
