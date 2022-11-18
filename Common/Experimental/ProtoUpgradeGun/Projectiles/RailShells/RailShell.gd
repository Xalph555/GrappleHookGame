#--------------------------------------#
# RailShell Script                     #
#--------------------------------------#
extends RayCast2D
class_name RailShell


# Variables:
#---------------------------------------
onready var laser_beam_line := $"LaserBeam"
onready var laser_beam_particles := $LaserBeam/BeamLength
onready var laser_beam_start_particles := $LaserBeam/BeamStart


# Functions:
#---------------------------------------
func _ready() -> void:
	enabled = false
	laser_beam_particles.emitting = false
	laser_beam_start_particles.emitting = false


func shoot(length : float, width : float, hit_layers : Array) -> void:
	for layer in hit_layers:
		set_collision_mask_bit(layer, true)

	cast_to.x = length
	enabled = true

	activate_beam(width, true)


func activate_beam(width : float, is_on : bool) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if is_on:
		# shell fire delay??

		# setting beam line
		laser_beam_line.visible = true

		laser_beam_line.points[0].x = width / 2.0
		laser_beam_line.points[1].x = cast_to.x

		laser_beam_line.width = 0.0
		
		tween.tween_property(laser_beam_line, "width", width, 0.8)

		# setting particles
		laser_beam_particles.position = cast_to / 2.0
		laser_beam_particles.process_material.emission_box_extents.x = cast_to.length() / 2.0
		laser_beam_particles.process_material.emission_box_extents.y = width / 2.0

		laser_beam_particles.emitting = true
		laser_beam_start_particles.emitting = true

	else:
		tween.tween_property(laser_beam_line, "width", width, 0.5)

		laser_beam_particles.emitting = false
		laser_beam_start_particles.emitting = false

		yield(tween, "finished")

		call_deferred("free")


# Signals Connections:
#-------------------------------------
func _on_Timer_timeout() -> void:
	activate_beam(0, false)
