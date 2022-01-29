#--------------------------------------#
# State Script                         #
#--------------------------------------#
# other states should extend/ inherit this

extends Node

class_name State


# Variables:
#---------------------------------------
var state_machine = null


# Functions:
#---------------------------------------
# virtual function
func handle_input(event : InputEvent) -> void:
	pass


# virtual function
func update(delta : float) -> void:
	pass


# virtual function
func physics_update(delta : float) -> void:
	pass


func enter(msg := {}) -> void:
	pass


func exit() -> void:
	pass
