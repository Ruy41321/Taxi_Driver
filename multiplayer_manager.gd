extends Node

const SERVER_PORT = 12345
const SERVER_IP = "172.31.46.0"

var current_room_id: String = ""

var public_rooms = {}  # Esempio: { "room_code": [peer_id1, peer_id2] }
var private_rooms = {}
var waiting_peer: int = -1

var is_host: bool = false

var player1_id = 0
var player2_id = 0

var level_node: Node = null

func _ready() -> void:
	pass

func is_server() -> bool:
	return is_host

######  Server side   ########
func become_host() -> void:
	var peer = ENetMultiplayerPeer.new()

	if peer.create_server(12345, 32) != OK:
		push_error("Errore nell'avvio del server dedicato")
		return
	multiplayer.multiplayer_peer = peer
	print("Relay server avviato: " + SERVER_IP + "::" + str(SERVER_PORT))
	is_host = true
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id):
	print("Peer connesso:", id)
	rpc_id(id, "connection_established")


@rpc("any_peer")
func join_room(room_id: String):
	var sender = multiplayer.get_remote_sender_id()
	#creazuibe stanza privata
	if room_id == "new_private":
		room_id = generate_room_id()
		private_rooms[room_id] = [sender]
		print("Stanza privata creata: ", room_id)
		rpc_id(sender, "room_created", room_id)
		return
	#quick_join
	if room_id == "quick_join":
		if waiting_peer == -1:
			waiting_peer = sender
			print("Peer", sender, "in attesa di un altro giocatore...")
			rpc_id(sender, "waiting_for_opponent")
		else:
			room_id = generate_room_id()
			public_rooms[room_id] = [waiting_peer, sender]
			print("Stanza creata: ", room_id, " con ", waiting_peer, " e ", sender)

			public_rooms[room_id].map(
				func(peer_id):
					rpc_id(peer_id, "start_game", room_id, public_rooms[room_id])
			)

			waiting_peer = -1
		return
	#ingresso stanza privata
	if private_rooms.has(room_id):
		if private_rooms[room_id].size() >= 2:
			print("Stanza piena: ", room_id)
			rpc_id(sender, "room_full", room_id)
			return
		if sender in private_rooms[room_id]:
			print("Sei già nella stanza privata: ", room_id)
			rpc_id(sender, "already_in_room", room_id)
			return
		private_rooms[room_id].append(sender)
		print("Peer", sender, "ti sei unito alla stanza privata: ", room_id)
		private_rooms[room_id].map(
			func(peer_id):
				rpc_id(peer_id, "start_game", room_id, public_rooms[room_id])
		)
		return
	else:
		print("Stanza privata non trovata: ", room_id)
		rpc_id(sender, "room_not_found", room_id)
		return

func _on_peer_disconnected(id):
	print("Server: Peer disconnesso:", id)

	if waiting_peer == id:
		waiting_peer = -1

	var room_to_remove = null
	var other_peer = -1

	#controlla se esiste la stanza dove il peer era connesso, se esiste, rimuove la stanza e notifica l'altro peer
	for room_id in public_rooms:
		var pair = public_rooms[room_id]
		if id in pair:
			for p in pair:
				if p != id:
					other_peer = p
			room_to_remove = room_id
			break
	if room_to_remove != null:
		public_rooms.erase(room_to_remove)
	else:
		for room_id in private_rooms:
			var pair = private_rooms[room_id]
			if id in pair:
				for p in pair:
					if p != id:
						other_peer = p
				room_to_remove = room_id
				break
	#notifica l'altro peer se presente
	if other_peer != -1:
		rpc_id(other_peer, "peer_disconnected", id)
	#rimuove la stanza se non è stata già rimossa
	if room_to_remove != null:
		private_rooms.erase(room_to_remove)

@rpc("any_peer")
func relay_message(room_id: String, msg: Dictionary):
	(
		public_rooms[room_id] if public_rooms.has(room_id) else 
			(
				private_rooms[room_id] if private_rooms.has(room_id) else 
					[]
			)
	).map(
		func(peer_id):
			if peer_id != multiplayer.get_remote_sender_id():
				rpc_id(peer_id, "receive_message", msg)
	)

func generate_room_id() -> String:
	var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
	var id = ""
		
	while(id == "" || public_rooms.has(id)):
		id = ""
		for i in range(6):
			id += chars[randi() % chars.length()]
	return id

######  Client side   ########

@rpc("authority")
func receive_message(msg: Dictionary):
	
	match msg.get("command"):
		"spawn_player":
			level_node.add_player(msg.get("authority_id"))
		"spawn_taxi":
			level_node.add_taxi(msg.get("authority_id"))
		"taxi_physics_process":
			var taxi = level_node.taxi_instance
			taxi.old_direction = msg.get("old_direction")
			if (msg.get("is_changed")):
				taxi.change_animation(taxi.old_direction)
			taxi.position = msg.get("position")
			if (msg.get("is_invested")):
				taxi.handle_invested()
		"player_movement":
			level_node.player_instance.velocity = msg.get("velocity")
			level_node.player_instance.direction = msg.get("direction")
			level_node.player_instance.is_running = msg.get("is_running")
			level_node.player_instance.position = msg.get("position")
			#level_node.player_instance.move_and_check()
		_:
			print("Unknown command received:", msg.get("command"))

func become_client(room_id):
	var client_peer = ENetMultiplayerPeer.new()

	if client_peer.create_client(SERVER_IP, SERVER_PORT) != OK:
		push_error("Errore nel client in connessione al server")
		return
	multiplayer.multiplayer_peer = client_peer
	print("Client connesso al server: " + SERVER_IP + "::" + str(SERVER_PORT))
	current_room_id = room_id

@rpc("authority")
func connection_established():
	print("Connection established with server.")
	rpc_id(1, "join_room", current_room_id)

func is_connection_open() -> bool:
	return multiplayer.multiplayer_peer != null

func quit_connection():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
		print("Disconnected from server.")

@rpc("authority")
func peer_disconnected(id):
	print("Peer disconnected with ID: ", id)
	quit_connection()
	if get_tree().current_scene.name == "Level1":
		get_tree().change_scene_to_file("res://scene/start_menu/start_menu.tscn")
	else:
		print(get_tree().current_scene.name)

var connection_status_label: Label

@rpc("authority")
func room_created(room_id: String) -> void:
	connection_status_label.visible = 1
	connection_status_label.text = "Room Created: " + room_id

@rpc("authority")
func waiting_for_opponent() -> void:
	connection_status_label.visible = 1
	connection_status_label.text = "Waiting for opponent..."

@rpc("authority")
func start_game(room_id: String, room: Array) -> void:
	current_room_id = room_id
	player1_id = room[0]
	player2_id = room[1]
	get_tree().change_scene_to_file("res://scene/level1/level1.tscn")

@rpc("authority")
func room_full(room_id: String) -> void:
	connection_status_label.visible = 1
	connection_status_label.text = "The Room \""+ room_id +"\" is already Full"

@rpc("authority")
func already_in_room(room_id: String) -> void:
	connection_status_label.visible = 1
	connection_status_label.text = "You are already in the Room: " + room_id

@rpc("authority")
func room_not_found(room_id: String) -> void:
	connection_status_label.visible = 1
	connection_status_label.text = "Room \""+ room_id +"\" not found"
