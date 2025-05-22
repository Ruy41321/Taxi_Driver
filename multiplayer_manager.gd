extends Node

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

func become_host():
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)

	multiplayer.multiplayer_peer = server_peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id):
	print("Client connected with ID: ", id)

func _on_peer_disconnected(id):
	print("Client disconnected with ID: ", id)

func become_client():
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)

	multiplayer.multiplayer_peer = client_peer