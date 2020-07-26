extends Spatial

onready var Player = preload("res://player/player.tscn")

onready var timers = $Timers
onready var spawn_points = $SpawnPoints.get_children()

var spawn_timer: Timer
var spawn_rate = 2

func _ready():
	add_players()


# add existing network players to game
func add_players():
	# create player objects and 
	for player_id in Network.players:
		var player = Player.instance()
		var random_spawn = get_random_spawn()
		
		player.name = str(player_id)
		player.set_network_master(player_id)
		player.hide()
		
		$Players.add_child(player)
		
		Network.rpc_id(player_id, "pre_start_game")
		
		print("added to game ", str(player_id))


# add a player to game
func add_player(player_id: int):
	var player = Player.instance()
	
	player.name = str(player_id)
	player.set_network_master(player_id)
	player.hide()
	
	$Players.add_child(player)
	
	Network.rpc_id(player_id, "pre_start_game")
	
	print("added late to game ", str(player_id))


# remove player data from games
func remove_player(player_id: int):
	$Players.get_node(str(player_id)).queue_free()


# spawn a player randomly into the game
func spawn_player(player_id: int):
	var player = $Players.get_node(str(player_id))
	
	if player:
		var spawn_pos = get_random_spawn()
		player.set_translation(spawn_pos)
		
		# this will freeze code execution for 2 seconds
		# it's a hacky spawn timer
		yield(get_tree().create_timer(2), "timeout")
		
		player.show()
		
		for _player_id in Network.players:
			rpc_id(_player_id, "spawn_player", player_id, spawn_pos)


# return a random spawn position
func get_random_spawn() -> Vector3:
	return spawn_points[randi() % spawn_points.size()].global_transform.origin
