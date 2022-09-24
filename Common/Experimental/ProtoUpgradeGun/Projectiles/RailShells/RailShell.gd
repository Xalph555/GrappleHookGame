#--------------------------------------#
# RailShell Script                     #
#--------------------------------------#
extends RayCast2D
class_name RailShell


# Variables:
#---------------------------------------
onready var laser_beam_line := $"LaserBeam"
onready var laser_beam_particles := $LaserBeam/Particles2D


# Functions:
#---------------------------------------
func _ready() -> void:
	enabled = false


func shoot(length : float, width : float, hit_layers : Array) -> void:
	for layer in hit_layers:
		set_collision_mask_bit(layer, true)

	cast_to.x = length

	laser_beam_line.points[1] = cast_to
	laser_beam_line.width = width

	laser_beam_particles.position = cast_to / 2.0
	laser_beam_particles.process_material.emission_box_extents.x = cast_to.length() / 2.0

	# shell fire delay??

	enabled = true
	laser_beam_line.visible = true


# Signals Connections:
#-------------------------------------
func _on_Timer_timeout() -> void:
	call_deferred("free")
