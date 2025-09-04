extends Control

@export var next_level_scene : PackedScene
@onready var settings_menu: Control = $SettingsMenu
@onready var main_menu: Control = $Panel
@onready var back_button: Button = $BackButton

var level_select : Node ##optional

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(next_level_scene)

func _on_settings_button_pressed() -> void:
	settings_menu.visible = true
	main_menu.visible = false
	back_button.visible = true


func _on_quit_button_pressed() -> void:
	get_tree().quit(0)


func _on_back_button_pressed() -> void:
	settings_menu.visible = false
	main_menu.visible = true
	back_button.visible = false
