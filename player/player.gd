extends KinematicBody

onready var movement_manager = $MovementManager

puppet var puppet_move_vec: Vector3
puppet var puppet_rotation_deg: Vector3

func _ready():
	movement_manager.init(self)

func _process(delta):
	rotation_degrees = puppet_rotation_deg
	movement_manager.set_move_vec(puppet_move_vec)
	
	
