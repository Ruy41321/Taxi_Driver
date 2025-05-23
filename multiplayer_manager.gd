extends Node

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var taxi_scene = preload("res://scene/Taxi/Taxi.tscn")
var player_scene = preload("res://scene/Player/Player.tscn")


var is_host = false
var player_id = 0

func become_host():
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)

	multiplayer.multiplayer_peer = server_peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id):
	print("Client connected with ID: ", id)
	player_id = id
	is_host = true
	get_tree().change_scene_to_file("res://scene/level1/level1.tscn")

func add_player():
	var player_instance = player_scene.instantiate()

	player_instance.name = "Player_" + str(player_id)
	player_instance.player_id = player_id
	player_instance.position = Vector2(600, 330)

	get_tree().get_current_scene().get_node("Players").add_child(player_instance)

func _on_peer_disconnected(id):
	print("Client disconnected with ID: ", id)

func become_client():
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)

	multiplayer.multiplayer_peer = client_peer
	get_tree().change_scene_to_file("res://scene/level1/level1.tscn")
