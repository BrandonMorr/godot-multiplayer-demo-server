extends Spatial

var body_to_move : KinematicBody = null

export var move_accel = 5
export var max_speed = 20
export var jump_force = 30
export var gravity = 50

var pressed_jump = false
var is_grounded = false
var frozen = false

var drag = 0.0

var move_vec: Vector3 
var velocity: Vector3
var snap_vec: Vector3

puppet var puppet_velocity: Vector3
puppet var puppet_position: Vector3
puppet var puppet_move_vec: Vector3

signal movement_info(velocity, is_grounded)

func _ready():
	drag = float(move_accel) / max_speed


func init(_body_to_move: KinematicBody):
	body_to_move = _body_to_move


puppet func jump():
	pressed_jump = true

func set_move_vec(_move_vec: Vector3):
	# Use normalized to round out the movement vector. This prevents
	# players from going faster diagonally.
	move_vec = _move_vec.normalized()


func _physics_process(delta):
	if frozen:
		return
	
	move_vec = puppet_move_vec
	
	velocity += move_accel * move_vec - velocity * Vector3(drag, 0, drag) + gravity * Vector3.DOWN * delta
	velocity = body_to_move.move_and_slide_with_snap(velocity, snap_vec, Vector3.UP)
	
	is_grounded = body_to_move.is_on_floor()
	
	if is_grounded:
		velocity.y = -0.01
	if is_grounded and pressed_jump:
		velocity.y = jump_force
		snap_vec = Vector3.ZERO
	else:
		snap_vec = Vector3.DOWN
	
	pressed_jump = false
	
	emit_signal("movement_info", velocity, is_grounded)


func freeze():
	frozen = true


func unfreeze():
	frozen = false
