extends KinematicBody2D


enum STATES {
	MOVE,
	ATTK_CHARGE_SLAM,
	ATTK_ORA_FLURRY,
	ATTK_BEYBLADE_ATTACK,
	ATTK_COMBO_ATTACK
}

export var ATTK_CHARGE_SLAM_charge_time := 3

var _state_previous = STATES.MOVE
var _state_current = STATES.MOVE

var _base_move_speed := 400
var _current_move_speed := 400
var _move_dir := Vector2.ZERO
var _velocity := Vector2.ZERO

var _target = null
var _target_follow_dist := 280

var _vector_to_target := Vector2.ZERO
var _dir_to_target := Vector2.ZERO
var _dist_to_target := 0.0

var _position_to_move := Vector2.ZERO
var _has_reached_position := false

onready var _anim_player := $AnimationPlayer
onready var _anim_tree := $AnimationTree
onready var _anim_tree_state = _anim_tree.get("parameters/playback")

onready var _next_attack_timer := $NextAttackTimer
onready var _attack_duration_timer := $AttackDuration


func _physics_process(delta: float) -> void:
	if _target:
		#update_target_variables()
		
		# simple state machine
		match _state_current:
			STATES.MOVE:
				state_move(delta)
				
			STATES.ATTK_CHARGE_SLAM:
				state_charge_slam(delta)
			
			STATES.ATTK_ORA_FLURRY:
				state_ora_flurry(delta)
			
			STATES.ATTK_BEYBLADE_ATTACK:
				state_beyblade_attack(delta)
			
			STATES.ATTK_COMBO_ATTACK:
				state_combo_attak(delta)
	
	else:
		_move_dir = Vector2.ZERO
	
	update_movement(delta)


func state_transition(new_state) -> void:
	match new_state:
		STATES.MOVE:
			_anim_tree_state.travel("Idle")
			
		STATES.ATTK_CHARGE_SLAM:
			_anim_tree_state.travel("ATTK_CHARGE_SLAMChargeUp")
			yield(get_tree().create_timer(ATTK_CHARGE_SLAM_charge_time), "timeout")
			
			_position_to_move = _target.global_position + Vector2(-50, -50)
			_move_dir = self.global_position.direction_to(_position_to_move)
			_has_reached_position = false
			_current_move_speed *= 4
			
			_anim_tree_state.travel("ATTK_CHARGE_SLAMRelease")
			_attack_duration_timer.start(1.5)
			
		STATES.ATTK_ORA_FLURRY:
			pass
			
			# rise up above the player (charge animation)
			# dash down and start flurry
			# have variable flurry time
			# get stuck in ground for a little bit
			
		STATES.ATTK_BEYBLADE_ATTACK:
			pass
			
			# Beyblade arms charge
			# start spinning actual attack
			# arms overheat - slower move speed
		
		STATES.ATTK_COMBO_ATTACK:
			pass
			
			# charge up
			# actual attack
			# arms overheat
		
	_state_previous = _state_current
	_state_current = new_state


func state_move(delta : float) -> void:
	follow_player()


func state_charge_slam(delta : float) -> void:
	if self.global_position.distance_to(_position_to_move) <= 600:
		_has_reached_position = true
	
	if _has_reached_position:
		_move_dir = Vector2.RIGHT


func state_ora_flurry(delta : float) -> void:
	pass


func state_beyblade_attack(delta : float) -> void:
	pass


func state_combo_attak(delta : float) -> void:
	pass


#func update_target_variables() -> void:
#	#var _target_vector = _target.global_position as Vector2
#
#	_vector_to_target = _target.global_position - self.global_position
#
#	_dir_to_target = self.global_position.direction_to(_target.global_position)
#	_dist_to_target = self.global_position.distance_to(_target.global_position)


func update_movement(delta : float) -> void:
	_velocity = _move_dir * _current_move_speed
	_velocity = move_and_slide(_velocity)


# attempt 2 at follow player code
func follow_player() -> void:
	var _dir_to_reach := Vector2.ZERO
	
	# keep track of point above player's head + follow distance
	# move towards that point always while following player
	# 	- slow and gradual transition so it does not seem afixed to player
	
	# (might require dead space due to move speed and distance from target)
	 
	_dir_to_target = self.global_position.direction_to(_target.global_position \
						+ Vector2(0, -_target_follow_dist))
						
	_dist_to_target = self.global_position.distance_to(_target.global_position \
						+ Vector2(0, -_target_follow_dist))
	
	if _dist_to_target > 200:
		_dir_to_reach = _dir_to_target
		
	else:
		_dir_to_reach = Vector2.ZERO
	
	_move_dir = lerp(_move_dir, _dir_to_reach, 0.05)


#func follow_player() -> void:
#	var _dir_to_reach := Vector2.ZERO
#
#	if _dist_to_target > _target_follow_dist + 20:
#		_dir_to_reach.x = _dir_to_target.x
#
#		# maintain vertical distance
#		if self.global_position.y > _target.global_position.y - 100:
#			_dir_to_reach.y = -1
#		else:
#			_dir_to_reach.y = _dir_to_target.y
#
#	elif _dist_to_target < _target_follow_dist - 20:
#		_dir_to_reach.x = -_dir_to_target.x
#
#		# maintain vertical distance
#		if self.global_position.y > _target.global_position.y - 100:
#			_dir_to_reach.y = -1
#		else:
#			_dir_to_reach.y = -_dir_to_target.y
#
#	else:
#		_dir_to_reach.x = 0
#
#		# maintain vertical distance
#		if self.global_position.y > _target.global_position.y - 100:
#			_dir_to_reach.y = -1
#		else:
#			_dir_to_reach.y = 0
#
#	_move_dir = lerp(_move_dir, _dir_to_reach, 0.1)


func _on_TargetRange_body_entered(body: Node) -> void:
	_target = body


func _on_TargetRange_body_exited(body: Node) -> void:
	#_target = null
	pass


func _on_NextAttackTimer_timeout() -> void:
	state_transition(STATES.ATTK_CHARGE_SLAM)


func _on_AttackDuration_timeout() -> void:
	_current_move_speed = _base_move_speed
	state_transition(STATES.MOVE)
	
	_next_attack_timer.start()
