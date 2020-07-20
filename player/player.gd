extends KinematicBody

var player_id: int
var velocity: Vector3

puppet var puppet_position: Vector3
puppet var puppet_velocity: Vector3

func _ready():
	player_id = get_network_master()
	
	# make sure we initialize the position
#	puppet_position = global_transform.origin

func _process(delta):
	pass
	# sync to last known position and velocity
#	global_transform.origin = puppet_position
#	velocity = puppet_velocity
	
#	self.move_and_slide_with_snap(velocity, Vector3.DOWN, Vector3.UP)
	
	# It may happen that many frames pass before the controlling player sends
	# their position again. If we don't update puppet_pos to position after moving,
	# we will keep jumping back until controlling player sends next position update.
	# Therefore, we update puppet_pos to minimize jitter problems
#	global_transform.origin = position
