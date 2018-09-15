extends Control


func _ready():
	# Called every time the node is added to the scene.
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_suceeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")
	pass

func _on_Host_pressed():
	if ($Connect/Name.text == ""):
		$Connect/ErrorLabel.text="Invalid name!"
		return

	$Connect.hide()
	$Players.show()
	$Connect/ErrorLabel.text = ""

	var player_name = $Connect/Name.text
	var tank_selected = $Connect/TankSelect.selected

	var player = {}
	player.player_name = player_name
	player.tank_selected = tank_selected

	gamestate.host_game(player) # Was player_name
	refresh_lobby()
	pass # replace with function body

func _on_Join_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return
	var ip = $Connect/IP.text
	if not ip.is_valid_ip_address():
		$Connect/ErrorLabel.text = "Invalid IPv4 Address!"
		return

	$Connect/ErrorLabel.text = ""
	$Connect/Host.disabled = true
	$Connect/Join.disabled = true

	var player_name = $Connect/Name.text
	var tank_selected = $Connect/TankSelect.selected
	
	var player = {}
	player.player_name = player_name
	player.tank_selected = tank_selected
	
	gamestate.join_game(ip, player)
	pass # replace with function body

func _on_connection_success():
	$Connect.hide()
	$Players.show()
	pass

func _on_connection_failed():
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false
	$Connect/ErrorLabel.set_text("Connection Failed")
	pass

func _on_game_ended():
	show()
	$Connect.show()
	$Players.hide()
	$Connect/Host.disabled = false
	$Connect/Join.disabled
	pass

func _on_game_error(error_text):
#	print(error_text)
	$Error.dialog_text = error_text
	$Error.popup_centered_minsize()
	pass

func refresh_lobby():
	var players = gamestate.get_player_list()
	players.sort()
	$Players/List.clear()
	$Players/List.add_item(gamestate.get_player_name() + " (You)")
	for p in players:
		$Players/List.add_item(p.player_name)

	$Players/Start.disabled = not get_tree().is_network_server()
	pass

func _on_Start_pressed():
	gamestate.begin_game()
	pass

