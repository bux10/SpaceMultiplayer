extends Node

const PORT = 1234
var tank = null
var m = null
var players = []
var map = load("res://Maps/Map01.tscn").instance()
var hud = load("res://ui/HUD.tscn").instance()

func _ready():
	tank = preload("res://tanks/MachineGunner.tscn")
	get_tree().connect("connected_to_server", self, "_connected_ok")

func on_host_game():
	var host = NetworkedMultiplayerENet.new()
	var selected_tank = get_node('/root/Lobby/Panel/HostRect/TankSelect').selected
	match selected_tank:
		0:tank = load("res://tanks/MachineGunner.tscn")
		1:tank = load("res://tanks/FlameThrower.tscn")
		2:tank = load("res://tanks/Engineer.tscn")

	# 4 is the number of maximum clients
	host.create_server(PORT, 4)
	get_tree().set_network_peer(host)
	_connected_ok()
 
func on_join_game(ip):
	var host = NetworkedMultiplayerENet.new()
	var selected_tank = get_node('/root/Lobby/Panel/JoinRect/TankSelect').selected
	match selected_tank:
		0:tank = load("res://tanks/MachineGunner.tscn")
		1:tank = load("res://tanks/FlameThrower.tscn")
		2:tank = load("res://tanks/Engineer.tscn")
	
	host.create_client(ip, PORT)
	get_tree().set_network_peer(host)


func _connected_ok():
	rpc("register_player", get_tree().get_network_unique_id())
	register_player(get_tree().get_network_unique_id())
	get_tree().get_root().get_node("Lobby").queue_free()
 
# this function is called when a new player is connected
# note the use of the keyword remote which mean that the code will only be called on the others
remote func register_player(player_id):
	var p = tank.instance()
	p.set_network_master(player_id)
	p.name = str(player_id)
#	p.title = str(player_id)
	#m.set_network_master(player_id)
	if player_id == 1:
		get_tree().get_root().add_child(map)
		map.get_node("Players").add_child(p)
		map.add_child(hud)
		hud.set_network_master(player_id)
		p.connect("health_changed", hud, "update_healthbar")
		p.connect("shoot", map, "_on_Tank_shoot")
		p.position = get_node('/root/Map/SpawnPoints/host').position
	else:
		map.get_node("Players").add_child(p)
		p.connect("health_changed", hud, "update_healthbar")
		p.connect("shoot", map, "_on_Tank_shoot")
#		print(get_node('/root/Map/SpawnPoints/join').position)
#		p.position = get_node('/root/Map/SpawnPoints/join').position
#	print(get_tree().get_root().get_children())
	# if I'm the server I inform the new connected player about the others


	if get_tree().get_network_unique_id() == 1:
		if player_id != 1:
			for i in players:
				rpc_id(player_id, "register_player", i)
		players.append(player_id)