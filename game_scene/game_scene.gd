extends Spatial

onready var Player = load("res://player/player.tscn")

var spawn_points: Array = []

func _ready():
	spawn_points = $SpawnPoints.get_children()


# add existing players to game
func add_players():
	# create player objects and 
	for player_id in Network.players:
		var player = Player.instance()
		
		player.name = str(player_id)
		player.set_network_master(player_id)
		
		$Players.add_child(player)
		
		print("added to game ", str(player_id))


# add a player to game
func add_player(player_id: int):
	var player = Player.instance()
	
	player.name = str(player_id)
	player.set_network_master(player_id)
	
	$Players.add_child(player)
	
	print("added, late to game ", str(player_id))


# remove player data from games
func remove_player(player_id: int):
	$Players.get_node(str(player_id)).queue_free()


# remove player data from games
func spawn_player(player_id: int):
	var player = $Players.get_node(str(player_id))
	
	if player:
		player.global_transform.origin = get_random_spawn()
		player.rset("puppet_position")


# return a random spawn position
func get_random_spawn() -> Vector3:
	return spawn_points[randi() % spawn_points.size()].global_transform.origin
