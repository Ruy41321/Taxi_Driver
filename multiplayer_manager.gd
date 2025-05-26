extends Node

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var is_host = false
var player_id = 0

func become_host():
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)

	multiplayer.multiplayer_peer = server_peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	
	#upnp_setup()

func _on_peer_connected(id):
	print("Client connected with ID: ", id)
	player_id = id
	is_host = true
	get_tree().change_scene_to_file("res://scene/level1/level1.tscn")

func _on_peer_disconnected(id):
	print("Client disconnected with ID: ", id)
	get_tree().change_scene_to_file("res://scene/start_menu/start_menu.tscn")

func become_client(ip):
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(ip, SERVER_PORT)

	multiplayer.multiplayer_peer = client_peer
	
	get_tree().change_scene_to_file("res://scene/level1/level1.tscn")

func delete_host():
	pass

func upnp_setup():
	var upnp = UPNP.new()

	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Discover Failed! Error %s" % discover_result)
	for i in upnp.get_device_count():
		var device = upnp.get_device(i)
		print("Description URL: " + str(device.description_url))
		print("IGD Status: " + str(device.igd_status))
		print("Is Valid Gateway: " + str(device.is_valid_gateway()))

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), "UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(SERVER_PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Port Mapping Failed! Error %s" % map_result)

	$ConnectionStatusLabel.text = "Your IP: %s\n" % [upnp.query_external_address()]
