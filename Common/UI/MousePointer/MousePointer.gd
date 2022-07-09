#--------------------------------------#
# Mouse Pointer Script                 #
#--------------------------------------#
extends Control
class_name MouseAimPointer


# Functions:
#---------------------------------------
var _player : Player

onready var _norm_pointer := $NormalPointer
onready var _dash_pointer := $DashPointer


# Functions:
#---------------------------------------
func set_up_ui(player_ref : Player) -> void:
	_player = player_ref

	# connect player signals
	_player.connect("grapple_start", self, "_on_grapple_start")
	_player.connect("grapple_end", self, "_on_grapple_end")

	_player.connect("dash_start", self, "_on_dash_start")
	_player.connect("dash_end", self, "_on_dash_end")


func _process(delta: float) -> void:
	rect_position = _player.get_global_transform_with_canvas().origin
	self.set_rotation((get_global_mouse_position() - self.rect_global_position).angle())

	if _player.is_flying:
		set_dash_pointer()
	else:
		set_normal_pointer()


func change_color(color : Color) -> void:
	self.modulate = color


func set_normal_pointer() -> void:
	_norm_pointer.visible = true
	_dash_pointer.visible = false


func set_dash_pointer() -> void:
	_norm_pointer.visible = false
	_dash_pointer.visible = true


# signal callbacks
func _on_grapple_start() -> void:
	self.visible = false

func _on_grapple_end() -> void:
	self.visible = true


func _on_dash_start() -> void:
	self.visible = false

func _on_dash_end() -> void:
	self.visible = true