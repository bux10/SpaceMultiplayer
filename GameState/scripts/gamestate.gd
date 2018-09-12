extends Node

# Default game port
const DEFAULT_PORT = 10567

# Max Players
const MAX_PLAYERS = 4

# Name for Local Player
var player_name = "Bux10"

# Names for remote players in id:name format
var players = {}

# Signals to let lobby GUI know what's happening
signal player_list_changed()
signal connection_failed()
signal connection_suceeded()
signal game_ended()
signal game_error(what)

# Callback from SceneTree
func _player_connected(id):
	# This is not used in this demo, because _connected_ok is called for clients
	# on success and will do the job.
	pass

# Callback from SceneTree
func _player_disconnected(id):
	if (get_tree().is_network_server()):
		if (has_node("/root/world")): # Game is in progress
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
		else: # Game is not in progress
			# If we are the server, send to the new dude all the already registered players
			unregister_player(id)
			for p_id in players:
				# Erase in the server
				rpc_id(p_id, "unregister_player", id)

# Callback from SceneTree, only for clients, not the server
func _connected_ok():
	# Registration of a client begins here, tell everyone that we are here
	rpc("register_player", get_tree().get_network_unique_id(), player_name)
	emit_signal("connection_succeeded")
	pass

# Callback from SceneTree, only for clients, not the server
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()
	pass

# Callback from SceneTree, only for clients, not the server
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")
	pass

# Lobby Mangement Functions

remote func register_player(id, new_player_name):
	if get_tree().is_network_server():
		# If we are the server, let everyone know about the new player
		rpc_id(id, "register_player", 1, player_name) # Send myself to new player
		for p_id in players: # Then for each remote player
			rpc_id(id, "register_player", p_id, players[p_id]) # Send other remote players to new player
			rpc_id(p_id, "register_player", id, new_player_name) # Send new player to other remote players

	players[id] = new_player_name
	emit_signal("player_list_changed")
	pass

remote func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")
	pass

remote func pre_start_game(spawn_points):
	# Change Scene
	var map = load("res://Maps/Map01.tscn").instance()
	get_tree().get_root().add_child(map)

	get_tree().get_root().get_node("Lobby").hide()

	var player_scene = load("res://tanks/MachineGunner.tscn") # TODO: This should be the selected tank

	for p_id in spawn_points:
		var spawn_pos = map.get_node("spawn_points/" + str(spawn_points[p_id])).position
		var player = player_scene.instance()

		player.set_name(str(p_id)) # Use unique ID as node name
		player.position = spawn_pos
		player.set_network_master(p_id) # Set unique ID as master

		if (p_id == get_tree().get_network_unique_id()):
			# If node for this peer, set name
			player.set_player_name(player_name)
		else:
			# Otherwise set name from peer
			player.set_player_name(player[p_id])

		map.get_node("Players").add_child(player)

	# Setup Score
	map.get_node("Score").add_player(get_tree().get_network_unique_id(), player_name)
	for pn in players:
		map.get_node("Score").add_player(pn, players[pn])

	if not get_tree().is_network_server():
		# Tell everyone we are ready to start
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()
	pass

remote func post_start_game():
	get_tree().set_pause(false) # Unpause and start game

var players_ready = []

remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()
	pass

func host_game(new_player_name):
	player_name = new_player_name
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(host)

func join_game(ip, new_player_name):
	player_name = new_player_name
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)

func get_player_list():
	return players.values()
	pass

func get_player_name():
	return player_name
	pass

func begin_game():
	assert(get_tree().is_network_server())

	# Create a dicionary with peer id and respective spawn points
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	# Call to pre-start game with spawn points
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)

	pre_start_game(spawn_points)

func end_game():
	if has_node("/root/Map"): # Game is in progress
		# End it
		get_node("/root/map").queue_free()

	emit_signal("game_ended")
	players.clear()
	get_tree().set_network_peer(null) # End networking

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

