extends Control

onready var player_list = $LobbyPanel/PlayerList

func _ready():
	Network.connect("players_updated", self, "_on_update_players")


func _on_update_players():
	player_list.clear()
	
	for player_id in Network.players:
		player_list.add_item(Network.players[player_id], null)
		player_list.set_item_metadata(player_list.get_item_count() - 1, player_id)


func _on_KickButton_pressed():
	if player_list.is_anything_selected():
		var selected_item = player_list.get_selected_items()
		var player_to_kick = player_list.get_item_metadata(selected_item[0])
		
		Network.kick_player(player_to_kick)
