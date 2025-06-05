extends MarginContainer

@onready var new_room_button : Button = $MultiplayerSelection/NewPrivateRoom
@onready var join_button : Button = $MultiplayerSelection/QuickJoin
@onready var room_id_label : LineEdit = $MultiplayerSelection/RoomId
@onready var connection_status_label : Label = $"../ConnectionStatusLabel"

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		MultiplayerManager.become_host()

	$MainMenu.visible = 1
	$PlayMenu.visible = 0
	$MultiplayerSelection.visible = 0

	new_room_button.pressed.connect(_on_new_room_pressed)
	join_button.pressed.connect(_on_join_pressed)
	MultiplayerManager.connection_status_label = connection_status_label

func _on_play_pressed() -> void:
	$MainMenu.visible = 0
	$PlayMenu.visible = 1

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_level_1_pressed() -> void:
	$PlayMenu.visible = 0
	$MultiplayerSelection.visible = 1
	#get_tree().change_scene_to_file("res://scene/level1/level1.tscn")


func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/level2/level2.tscn")

func _on_new_room_pressed() -> void:
	MultiplayerManager.become_client("new_private")
	new_room_button.visible = 0
	join_button.visible = 0
	room_id_label.visible = 0
	
func _on_join_pressed() -> void:
	if room_id_label.text == "":
		MultiplayerManager.become_client("quick_join")
	else:
		MultiplayerManager.become_client(room_id_label.text)
	new_room_button.visible = 0
	join_button.visible = 0
	room_id_label.visible = 0
	

func _on_back_pressed() -> void:
	if MultiplayerManager.is_connection_open():
		MultiplayerManager.quit_connection()
	$MainMenu.visible = 1
	$PlayMenu.visible = 0
	new_room_button.visible = 1
	join_button.visible = 1
	room_id_label.visible = 1
	connection_status_label.visible = 0
	$MultiplayerSelection.visible = 0
	
func _on_ip_address_text_changed(new_text: String) -> void:
	if new_text == "":
		join_button.text = "Quick Join"
		new_room_button.disabled = true
	else:
		join_button.text = "Join"
		new_room_button.disabled = false

func _on_server_pressed() -> void:
	MultiplayerManager.become_host()
