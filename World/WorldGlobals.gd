extends Node



var gravity := 40


func apply_gravity(weight: float) -> float:
	return gravity + weight
