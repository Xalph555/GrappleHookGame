#--------------------------------------#
# World Globals Script                 #
#--------------------------------------#

extends Node

# Variables
#---------------------------------------
var gravity := 40



# Functions:
#---------------------------------------
func apply_gravity(weight: float) -> float:
	return gravity + weight
