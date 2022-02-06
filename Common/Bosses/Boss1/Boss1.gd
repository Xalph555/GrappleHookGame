#--------------------------------------#
# Boss1 Script                         #
#--------------------------------------#
extends KinematicBody2D

class_name BossCatArms


# Signals:
#---------------------------------------
signal boss_health_changed(health)


# Variables:
#---------------------------------------
enum STATES {
	DEAD,
	OVERHEAT,
	MOVE,
	ATTK_CHARGE_SLAM,
	ATTK_ORA_FLURRY,
	ATTK_BEYBLADE_ATTACK,
	ATTK_COMBO_ATTACK
}

export var attack1_charge_time := 3.0
export var attack1_duration := 1

export var ora_flurry_charge_time := 3.0
export var ora_flurry_duration := 2.0

export var beyblade_charge_time := 2.0
export var beyblade_duration := 4.0

export var combo_charge_time := 2.0
export var combo_duration := 4.8 # same time as animation length

export var max_health := 200
onready var current_health := max_health

export var points := 10000

var _state_previous = STATES.MOVE
var _state_current = STATES.MOVE

var _attack_pattern := [STATES.ATTK_CHARGE_SLAM,
						STATES.ATTK_ORA_FLURRY,
						STATES.ATTK_BEYBLADE_ATTACK,
						STATES.ATTK_COMBO_ATTACK]
var _attack_pattern_index := 0

var _can_attack := false

var _base_move_speed := 400
var _current_move_speed := 400
var _move_dir := Vector2.ZERO
var _velocity := Vector2.ZERO

var _target = null
var _target_follow_dist_base := 280
var _target_follow_dist := 280

var _vector_to_target := Vector2.ZERO
var _dir_to_target := Vector2.ZERO
var _dist_to_target := 0.0

var _position_to_move := Vector2.ZERO
var _has_reached_position := false

onready var _anim_player := $AnimationPlayer
onready var _anim_tree := $AnimationTree
onready var _anim_tree_state = _anim_tree.get("parameters/playback")

onready var _arm_cooldown_timer := $ArmCooldown
onready var _next_attack_timer := $NextAttackTimer
onready var _attack_duration_timer := $AttackDuration


# Functions:
#---------------------------------------
func _ready() -> void:
	randomize()
	_attack_pattern.shuffle()


func _physics_process(delta: float) -> void:
	if _target:
		# simple state machine
		match _state_current:
			STATES.DEAD:
				state_dead()
				
			STATES.OVERHEAT:
				state_overheat(delta)
			
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
		STATES.DEAD:
			_position_to_move = self.global_position + Vector2(0, 200)
			_move_dir = self.global_position.direction_to(_position_to_move)
			_has_reached_position = false
			
			_anim_tree_state.travel("Death")
			
		STATES.OVERHEAT:
			_position_to_move = self.global_position + Vector2(0, 300)
			_move_dir = self.global_position.direction_to(_position_to_move)
			_has_reached_position = false
			
			_anim_tree_state.travel("OverHeatArms")
			_arm_cooldown_timer.start()
		
		STATES.MOVE:
			_can_attack = false
			_anim_tree_state.travel("Idle")
			
		STATES.ATTK_CHARGE_SLAM:
			_anim_tree_state.travel("Attack1ChargeUp")
			yield(get_tree().create_timer(attack1_charge_time), "timeout")
			
			_position_to_move = _target.global_position + Vector2(-50, -50)
			_move_dir = self.global_position.direction_to(_position_to_move)
			_has_reached_position = false
			_current_move_speed *= 4
			
			_anim_tree_state.travel("Attack1Release")
			_attack_duration_timer.start(attack1_duration)
			
		STATES.ATTK_ORA_FLURRY:
			_anim_tree_state.travel("OraFlurryCharge")
			_target_follow_dist += 100
			yield(get_tree().create_timer(ora_flurry_charge_time), "timeout")
			
			_position_to_move = _target.global_position + Vector2(0, -_target_follow_dist)
			_move_dir = self.global_position.direction_to(_position_to_move)
			_has_reached_position = false
			_current_move_speed *= 5
			
			_anim_tree_state.travel("OraFlurry")
			_attack_duration_timer.start(ora_flurry_duration)
			
		STATES.ATTK_BEYBLADE_ATTACK:
			_anim_tree_state.travel("BeyBladeArmsCharge")
			yield(get_tree().create_timer(beyblade_charge_time), "timeout")
			
			_current_move_speed *= 0.6
			
			_anim_tree_state.travel("BeyBladeArms")
			_attack_duration_timer.start(beyblade_duration)
		
		STATES.ATTK_COMBO_ATTACK:
			_anim_tree_state.travel("ComboAttackCharge")
			yield(get_tree().create_timer(combo_charge_time), "timeout")
			
			_current_move_speed *= 0.8
			
			_anim_tree_state.travel("ComboAttack")
			_attack_duration_timer.start(combo_duration)
		
	_state_previous = _state_current
	_state_current = new_state


func state_dead() -> void:
	_arm_cooldown_timer.stop()
	_next_attack_timer.stop()
	_attack_duration_timer.stop()
		
	if self.global_position.distance_to(_position_to_move) <= 100:
		_has_reached_position = true
	
	if _has_reached_position:
		_move_dir = Vector2.ZERO


func state_overheat(delta : float) -> void:
	if self.global_position.distance_to(_position_to_move) <= 100:
		_has_reached_position = true
	
	if _has_reached_position:
		_move_dir = Vector2.ZERO


func state_move(delta : float) -> void:
	start_attack_timer()
	follow_player()


func state_charge_slam(delta : float) -> void:
	if self.global_position.distance_to(_position_to_move) <= 600:
		_has_reached_position = true
	
	if _has_reached_position:
		_move_dir = Vector2.RIGHT


func state_ora_flurry(delta : float) -> void:
	if self.global_position.distance_to(_position_to_move) <= 400:
		_has_reached_position = true
	
	if _has_reached_position:
		_move_dir = Vector2.ZERO


func state_beyblade_attack(delta : float) -> void:
	follow_player()


func state_combo_attak(delta : float) -> void:
	follow_player()


func increase_follow_dist(distance : float) -> void:
	_target_follow_dist += distance


func reset_values() -> void:
	_current_move_speed = _base_move_speed
	_target_follow_dist = _target_follow_dist_base


func update_movement(delta : float) -> void:
	_velocity = _move_dir * _current_move_speed
	_velocity = move_and_slide(_velocity)


func follow_player() -> void:
	var _dir_to_reach := Vector2.ZERO
	 
	_dir_to_target = self.global_position.direction_to(_target.global_position \
						+ Vector2(0, -_target_follow_dist))
						
	_dist_to_target = self.global_position.distance_to(_target.global_position \
						+ Vector2(0, -_target_follow_dist))
	
	# adjust move speed
	if _dist_to_target > 500:
		_current_move_speed = _base_move_speed * 2
	
	elif _dist_to_target > 150:
		_current_move_speed = _base_move_speed
	
	# adjust movement direction
	if _dist_to_target > 100:
		_dir_to_reach = _dir_to_target
		
		
	else:
		_dir_to_reach = Vector2.ZERO
	
	_move_dir = lerp(_move_dir, _dir_to_reach, 0.05)


func start_attack_timer() -> void:
	if !_can_attack:
		if _dist_to_target < 80:
			_can_attack = true
			_next_attack_timer.start()
			print("next attack timer start")


func _on_TargetRange_body_entered(body: Node) -> void:
	_target = body
	
	if !_target.is_boss_fight:
		_target.is_boss_fight = true
		GameEvents.emit_signal("boss_fight_start", self)


func _on_TargetRange_body_exited(body: Node) -> void:
	#_target = null
	pass


func _on_NextAttackTimer_timeout() -> void:
	if _attack_pattern_index == _attack_pattern.size():
		_attack_pattern.shuffle()
		_attack_pattern_index = 0
	
	state_transition(_attack_pattern[_attack_pattern_index])
	#print(_attack_pattern[_attack_pattern_index])
	
	_attack_pattern_index += 1


func _on_AttackDuration_timeout() -> void:
	reset_values()
	
	# will likely need to change this implementation - feels like it might 
	# sprial out of control if we decide to expand this boss
	match _state_current:
		STATES.ATTK_ORA_FLURRY:
			state_transition(STATES.OVERHEAT)
		
		STATES.ATTK_BEYBLADE_ATTACK:
			state_transition(STATES.OVERHEAT)
		
		STATES.ATTK_COMBO_ATTACK:
			state_transition(STATES.OVERHEAT)
		
		_:
			state_transition(STATES.MOVE)


func _on_ArmCooldown_timeout() -> void:
	state_transition(STATES.MOVE)


func _on_HurtBox_area_entered(area: Area2D) -> void:
	current_health -= area.damage
	emit_signal("boss_health_changed", current_health)
	
	if current_health <= 0 and _state_current != STATES.DEAD:
#		_arm_cooldown_timer.stop()
#		_next_attack_timer.stop()
#		_attack_duration_timer.stop()
		
		state_transition(STATES.DEAD)
		PlayerStats.score += points
		GameEvents.emit_signal("boss_fight_end")
