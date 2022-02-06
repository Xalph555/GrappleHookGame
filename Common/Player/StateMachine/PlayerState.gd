#--------------------------------------#
# Player State Script                  #
#--------------------------------------#
# other Player states should extend/ inherit this

# boiler plate code to get proper code completion working

extends State

class_name PlayerState


# Variables:
#---------------------------------------
var player: Player


# Functions:
#---------------------------------------
func _ready() -> void:
	yield(owner, "ready")
	player = owner as Player
	assert(player != null)
