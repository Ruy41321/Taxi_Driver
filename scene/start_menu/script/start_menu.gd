extends MarginContainer

@onready var host_button : Button = $MultiplayerSelection/Host
@onready var join_button : Button = $MultiplayerSelection/Join

func _ready() -> void:
	$MainMenu.visible = 1
	$PlayMenu.visible = 0
	$MultiplayerSelection.visible = 0

	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)

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

var is_host : bool = false

func _on_host_pressed() -> void:
	MultiplayerManager.become_host()
	is_host = true
	$MultiplayerSelection/Host.visible = 0
	$MultiplayerSelection/Join.visible = 0
	$MultiplayerSelection/IpAddress.visible = 0
	$"../ConnectionStatusLabel".visible = 1
	
func _on_join_pressed() -> void:
	if $MultiplayerSelection/IpAddress.text == "":
		return
	MultiplayerManager.become_client($MultiplayerSelection/IpAddress.text)
	$MultiplayerSelection.visible = 0
	

func _on_back_pressed() -> void:
	if is_host:
		MultiplayerManager.delete_host()
		is_host = false
	$MainMenu.visible = 1
	$PlayMenu.visible = 0
	$MultiplayerSelection/Host.visible = 1
	$MultiplayerSelection/Join.visible = 1
	$MultiplayerSelection/IpAddress.visible = 1
	$"../ConnectionStatusLabel".visible = 0
	
