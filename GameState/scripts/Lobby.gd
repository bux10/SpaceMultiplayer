extends Control


func _ready():
	# Called every time the node is added to the scene.
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")
	pass


func _on_Start_pressed():
	if (get_node("connect/name").text == ""):
		get_node("connect/error_label").text="Invalid name!"
		return
	pass # replace with function body


func _on_Host_pressed():
	if (get_node("connect/name").text == ""):
		get_node("connect/error_label").text="Invalid name!"
		return
	pass # replace with function body


func _on_Join_pressed():
	pass # replace with function body
