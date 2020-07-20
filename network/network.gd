extends Node

# defaults
const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 3000
const MAX_CONNECTIONS = 20

var players = {}
var ready_players = []

signal connection_succeeded
signal connection_failed
signal players_updated

func _ready():
	# set up "on connection/disconnection" event callbacks
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	
	create_server()


# callback when peer has connected to server
func _on_player_connected(player_id: int):
	print("client ", player_id, " connected")


# callback when peer has disconnected from server
func _on_player_disconnected(player_id: int):
	if players.has(player_id):
		rpc("unregister_player", player_id)
		
		unregister_player(player_id)
	
	print("client ", player_id, " disconnected")


# create a server, called on startup
func create_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_CONNECTIONS)
	
	get_tree().set_network_peer(peer)


# register new player with server
remote func register_player(new_player_name: String):
	var caller_id = get_tree().get_rpc_sender_id()
	
	# notify new player of existing players
	for player_id in players:
		rpc_id(caller_id, "register_player", player_id, players[player_id])
	
	# add new player to players dictionary
	players[caller_id] = new_player_name
	
	# notify players of new player
	rpc("register_player", caller_id, new_player_name)
	
	emit_signal("players_updated")
	
	# if a game is in progress, add player to go
	if has_node("/root/Game"):
		var game = get_node("/root/Game")
		game.add_player(caller_id)
		
		for player_id in players:
			if player_id != caller_id:
				game.rpc_id(player_id, "add_player", caller_id)
		
		rpc_id(caller_id, "pre_start_game")


func unregister_player(player_id: int):
	players.erase(player_id)
	
	emit_signal("players_updated")
	
	# if a game is in progress, remove player from game
	if has_node("/root/Game"):
		var game_players = get_node("/root/Game/Players").get_children()
		
		for player in game_players:
			if player.name == str(player_id):
				# tell everyone to remove the player from their game
				var game = get_node("/root/Game")
				game.remove_player(player_id)
				game.rpc("remove_player", player_id)


# receieved when a player has been kicked by the server
func kick_player(player_id: int):
	rpc_id(player_id, "player_kicked")
	
	if players.has(player_id):
		rpc("unregister_player", player_id)
	
	print("client ", player_id, " kicked from the game")


# receieved when a player has left the game
remote func player_left(player_id: int):
	if players.has(player_id):
		rpc("unregister_player", player_id)
	
	print("client ", player_id, " left the game")


# received when a player is ready in the lobby
remote func player_ready():
	var caller_id = get_tree().get_rpc_sender_id()
	
	if not ready_players.has(caller_id):
		ready_players.append(caller_id)
	
	if ready_players.size() == players.size():
		pre_start_game()


# instanciate game scene and signal to players to pre start game
func pre_start_game():
	get_node("/root/Menu").hide()
	
	var game = load("res://game_scene/game_scene.tscn").instance()
	get_tree().get_root().add_child(game)
	game.add_players()
	
	for player_id in players:
		rpc_id(player_id, "pre_start_game")


# notify caller to add players to game
remote func post_start_game():
	var caller_id = get_tree().get_rpc_sender_id()
	
	var game = get_node("/root/Game")
	game.rpc_id(caller_id, "add_players", players)


func end_game():
	if has_node("/root/Game"):
		get_node("/root/Game").queue_free()


# return an array of player names
func get_player_names() -> Array:
	return players.values()

# return an array of player IDs
func get_player_ids() -> Array:
	return players.keys()
